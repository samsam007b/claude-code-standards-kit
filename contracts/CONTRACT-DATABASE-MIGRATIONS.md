# Contract — Database Migrations

> SQWR Project Kit contract module.
> Standards: Martin Fowler "Evolutionary Database Design" (martinfowler.com, 2016), AWS Well-Architected Framework — Reliability Pillar, PostgreSQL 16 documentation, Supabase CLI documentation, Flyway documentation.

---

## Scientific Foundations

**Database schema changes are irreversible in production without a rollback plan.** Unlike application code, a dropped column or deleted table cannot be "hot-patched." Zero-downtime migrations require specific patterns to avoid locking tables or breaking running application versions during deployment.

Martin Fowler & Pramod Sadalage formalized the **Expand-Contract** (also called Parallel Change) pattern as the canonical approach for backward-incompatible schema changes in continuously deployed systems.

---

## 1. Migration Files & Naming (15 pts)

### 1.1 File Naming Convention

```
YYYYMMDD_HHMMSS_description.sql
```

Examples:
```
20260330_143000_add_user_preferences_table.sql
20260331_090000_rename_status_to_state_in_orders.sql
20260401_120000_add_index_on_users_email.sql
```

Rules:
- One migration = one logical change (do not bundle unrelated schema changes)
- Description must be human-readable (not `migration_001.sql` or `fix.sql`)
- Use snake_case for descriptions

Source: Flyway documentation (flywaydb.org/documentation/concepts/migrations), Liquibase naming conventions

### 1.2 Migration Files Are Immutable

Once a migration file is committed and run in **any** environment:
- **NEVER modify it** — create a new migration to fix or reverse a previous one
- Validate checksums in CI to detect modified migrations
- A modified migration that has already run will cause deployment failures

```bash
# Flyway checksum validation (run in CI)
flyway validate
# or: Supabase migration status
supabase migration list
```

Source: Flyway documentation §Checksums (flywaydb.org/documentation/concepts/checksums), Liquibase Change Log Constraints

### 1.3 Rollback Strategy

- Every migration SHOULD have a corresponding rollback (down migration) unless rollback is impossible
- If rollback is impossible (data loss risk), document explicitly:
  ```sql
  -- IRREVERSIBLE: drops column 'legacy_id' — data cannot be recovered after this migration
  ALTER TABLE users DROP COLUMN legacy_id;
  ```
- Test rollback scripts in staging before deploying migration to production
- Keep rollback scripts in the same versioned directory as forward migrations

Source: Martin Fowler & Pramod Sadalage "Evolutionary Database Design" (Fowler & Sadalage, 2003 — revised 2016, martinfowler.com/articles/evodb.html)

---

## 2. Zero-Downtime Patterns (30 pts)

### 2.1 Expand-Contract Pattern (Parallel Change)

For any backward-incompatible change (rename, remove, type change), always use 3 phases:

**Phase 1 — Expand:** Add new column alongside old one. Write to both. Deploy app reading new column.
```sql
-- Migration: add new column
ALTER TABLE orders ADD COLUMN state TEXT;
-- Application: write to both 'status' (old) and 'state' (new)
```

**Phase 2 — Migrate:** Backfill existing rows.
```sql
UPDATE orders SET state = status WHERE state IS NULL;
```

**Phase 3 — Contract:** Remove old column once all app instances are on the new version.
```sql
-- Only after 100% of app instances use 'state' instead of 'status'
ALTER TABLE orders DROP COLUMN status;
```

Violating this causes downtime or data corruption: an old app version still reading the dropped column returns errors for all users.

Source: Martin Fowler, "Parallel Change" (martinfowler.com/bliki/ParallelChange.html, 2012)

### 2.2 CREATE INDEX CONCURRENTLY

| Command | Lock type | Impact |
|---------|-----------|--------|
| `CREATE INDEX` (standard) | ACCESS EXCLUSIVE | Blocks ALL reads AND writes — causes downtime |
| `CREATE INDEX CONCURRENTLY` | SHARE UPDATE EXCLUSIVE | Allows concurrent reads and writes |

```sql
-- WRONG — blocks table during index build
CREATE INDEX idx_users_email ON users(email);

-- CORRECT — zero-downtime index creation
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
```

**Caveat:** `CONCURRENTLY` cannot run inside a transaction block — run it outside `BEGIN/COMMIT`.

Source: PostgreSQL 16 documentation §11.12 (Building Indexes Concurrently)

### 2.3 Adding Constraints Without Downtime

**NOT NULL with default (PostgreSQL ≥12):**
```sql
-- PostgreSQL ≥12: adding NOT NULL with a non-volatile default is fast (no rewrite)
ALTER TABLE users ADD COLUMN verified BOOLEAN NOT NULL DEFAULT false;
```

**FOREIGN KEY without table lock:**
```sql
-- Step 1: add constraint without validating existing rows (fast, minimal lock)
ALTER TABLE orders ADD CONSTRAINT fk_orders_user
  FOREIGN KEY (user_id) REFERENCES users(id) NOT VALID;

-- Step 2 (separate transaction, later): validate existing rows (SHARE UPDATE EXCLUSIVE only)
ALTER TABLE orders VALIDATE CONSTRAINT fk_orders_user;
```

- `NOT VALID` takes only a brief lock for new rows (future inserts/updates are validated)
- `VALIDATE CONSTRAINT` validates existing rows with a lighter lock, can run concurrently with reads

Source: PostgreSQL 16 documentation §5.4.5 (Not-null constraints), AWS RDS Best Practices for PostgreSQL

---

## 3. Supabase-Specific Patterns (20 pts)

### 3.1 Migration Workflow

```bash
# Create a new migration file (auto-generates timestamp)
supabase migration new add_user_preferences_table

# Generate diff between current local schema and migration files
supabase db diff --use-migra

# Apply pending migrations to remote (production) database
supabase db push

# Reset local database to match all migration files from scratch
supabase db reset

# Check migration status (which are applied vs. pending)
supabase migration list
```

Source: Supabase CLI documentation (supabase.com/docs/reference/cli/supabase-migration)

### 3.2 RLS Policy Changes

```sql
-- ALWAYS wrap policy changes in a transaction to avoid window with no policy
BEGIN;

DROP POLICY IF EXISTS "Users can read own profile" ON profiles;

CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = user_id);

COMMIT;
```

After creating any new table, IMMEDIATELY enable RLS:
```sql
ALTER TABLE new_table ENABLE ROW LEVEL SECURITY;
-- Then define policies before exposing the table to the API
```

Source: Supabase Row Level Security documentation, PostgreSQL Row Security Policy docs

### 3.3 Seed Data Separation

```
supabase/
  migrations/     ← schema changes (immutable, versioned)
  seed.sql        ← reference data, default values (NOT a migration)
```

- `seed.sql` is re-run on `supabase db reset` — make it **idempotent** (can run multiple times without duplicates)

```sql
-- Idempotent seed example using ON CONFLICT
INSERT INTO subscription_plans (id, name, price_monthly)
VALUES
  ('free', 'Free', 0),
  ('pro', 'Pro', 29)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  price_monthly = EXCLUDED.price_monthly;
```

Source: Supabase CLI documentation §Local Development

---

## 4. Large Table Operations (20 pts)

### 4.1 Backfill Strategy for Large Tables (>1M rows)

Never run a single UPDATE on an entire large table — use batched updates:

```sql
DO $$
DECLARE batch_size INT := 2000;
DECLARE updated INT;
BEGIN
  LOOP
    UPDATE my_table
    SET new_column = compute_value(old_column)
    WHERE new_column IS NULL
    LIMIT batch_size;

    GET DIAGNOSTICS updated = ROW_COUNT;
    EXIT WHEN updated = 0;

    PERFORM pg_sleep(0.01);  -- 10ms delay reduces lock pressure
  END LOOP;
END $$;
```

Recommended batch size: **1000–5000 rows per UPDATE** with 10ms delay between batches.

Source: AWS RDS Best Practices for PostgreSQL (aws.amazon.com/blogs/database), Shopify Engineering Blog — "Avoiding Connection Pool Overhead" (shopify.engineering, 2021) [verify URL before citing]; cf. PostgreSQL connection pooling docs (postgresql.org/docs/current/runtime-config-connection.html)

### 4.2 Migration Time Limits

| Table size | Expected migration time | Strategy |
|------------|------------------------|----------|
| <10M rows | <30 minutes | Standard migration with CONCURRENTLY |
| >10M rows | Variable | Batched online DDL — no single long transaction |

- Always run `EXPLAIN ANALYZE` on migration queries before production deployment
- Migrations running >30 minutes should be redesigned with batching or online DDL

Source: AWS Well-Architected Framework — Reliability Pillar (aws.amazon.com/architecture/well-architected)

---

## 5. CI/CD Integration (15 pts)

### 5.1 Automated Migration Tests in CI

Every PR containing migration files MUST trigger a CI job that:
1. Spins up a fresh database (supabase local or Docker)
2. Runs all migrations from the beginning (`supabase db reset`)
3. Runs rollback scripts immediately after forward migrations
4. Runs the application's test suite against the migrated schema

```yaml
# .github/workflows/migration-test.yml
- name: Test migrations
  run: |
    supabase start
    supabase db reset  # applies all migrations from scratch
    npm run test
```

### 5.2 Schema Diff in PR Review

```bash
# Generate diff in CI and post as PR comment
supabase db diff --use-migra > schema_diff.txt
```

- Schema diffs must be included in every PR that adds migration files
- Reviewers must explicitly approve schema changes (required CI check)

Source: Supabase CI/CD documentation (supabase.com/docs/guides/cli/github-action)

---

## 6. Measurable Thresholds Summary

| Rule | Threshold | Standard |
|------|-----------|---------|
| Migration execution time (tables <10M rows) | <30 minutes | AWS Well-Architected |
| Batch update size (large tables) | 1000–5000 rows | AWS RDS Best Practices |
| Index creation | Always CONCURRENTLY (on tables with traffic) | PostgreSQL 16 docs |
| Foreign key constraint | NOT VALID + separate VALIDATE CONSTRAINT | PostgreSQL 16 docs |
| Seed data | Must be idempotent (ON CONFLICT or IF NOT EXISTS) | Supabase CLI docs |

---

## 7. Sources

| Reference | Link |
|-----------|------|
| Martin Fowler — Evolutionary Database Design | martinfowler.com/articles/evodb.html |
| Martin Fowler — Parallel Change | martinfowler.com/bliki/ParallelChange.html |
| PostgreSQL 16 — Building Indexes Concurrently | postgresql.org/docs/current/sql-createindex.html |
| PostgreSQL 16 — Row Security Policies | postgresql.org/docs/current/ddl-rowsecurity.html |
| AWS Well-Architected — Reliability Pillar | aws.amazon.com/architecture/well-architected |
| AWS RDS Best Practices for PostgreSQL | aws.amazon.com/blogs/database |
| Supabase CLI Reference | supabase.com/docs/reference/cli |
| Flyway Documentation | flywaydb.org/documentation |
| Liquibase Documentation | docs.liquibase.com |

---

> **Last validated:** 2026-03-30 — Martin Fowler Evolutionary Database Design 2016, PostgreSQL 16 docs, AWS Well-Architected Framework, Supabase CLI docs, Flyway docs
