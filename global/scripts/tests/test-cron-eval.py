#!/usr/bin/env python3
"""test-cron-eval.py: test suite for lib/cron-eval.py (fake job names, fixed clock).

Run: python3 global/scripts/tests/test-cron-eval.py
"""
import datetime
import importlib.util
import pathlib
import sys

spec = importlib.util.spec_from_file_location(
    "cron_eval", pathlib.Path(__file__).resolve().parent.parent / "lib" / "cron-eval.py")
ce = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ce)

NOW = datetime.datetime(2026, 1, 14, 15, 55, tzinfo=datetime.timezone.utc)


def reasons(*lines):
    _, late = ce.evaluer(list(lines), NOW)
    return {name: reason for name, _, reason in late}


CASES = []


def case(name):
    def deco(f):
        CASES.append((name, f))
        return f
    return deco


@case("healthy job: nothing reported")
def _():
    assert reasons("[active]|2026-01-15T06:30:00+00:00|2026-01-14T06:30:00+00:00|daily-report|30 6 * * *||ok") == {}


@case("last run failed: reported with the reason (HTTP 429)")
def _():
    m = reasons("[active]|2026-01-15T06:30:00+00:00|2026-01-14T06:30:47+00:00|daily-digest|30 6 * * *||"
                "error: RuntimeError: HTTP 429: rate limited")
    assert "failed" in m["daily-digest"] and "429" in m["daily-digest"], m


@case("weekly slot consumed without execution")
def _():
    m = reasons("[active]|2026-01-19T07:00:00+00:00|2026-01-05T22:54:20+00:00|weekly-scan|0 7 * * 1||ok")
    assert "without execution" in m["weekly-scan"], m


@case("same schedule, job did run: nothing reported")
def _():
    assert reasons("[active]|2026-01-19T07:00:00+00:00|2026-01-12T07:00:45+00:00|weekly-sync|0 7 * * 1||ok") == {}


@case("hour list: period overestimated, must never shout")
def _():
    assert reasons("[active]|2026-01-15T08:00:00+00:00|2026-01-14T15:08:34+00:00|twice-daily|0 8,15 * * *||ok") == {}


@case("non-deducible schedule: stay quiet rather than guess")
def _():
    assert ce.periode_s("15 5 * * 1-5") is None
    assert reasons("[active]|2026-01-15T05:15:00+00:00|2025-12-01T05:16:00+00:00|weekdays|15 5 * * 1-5||ok") == {}


@case("ordinary paused job is not an outage")
def _():
    assert reasons("[paused]|2026-01-01T07:15:00+00:00|2025-12-31T07:20:39+00:00|old-campaign|15 7 * * *||ok") == {}


@case("paused monitor: the pause IS the outage")
def _():
    m = reasons("[paused]|2026-01-14T16:46:00+00:00|2026-01-14T10:46:00+00:00|disk-watchdog|every 360m||ok")
    assert "PAUSED" in m["disk-watchdog"], m


@case("stuck scheduler: next slot in the past")
def _():
    m = reasons("[active]|2026-01-14T06:00:00+00:00|2026-01-14T05:00:00+00:00|health-check|every 30m||ok")
    assert "overdue" in m["health-check"], m


@case("never-run job: neither fresh nor late")
def _():
    fresh, late = ce.evaluer(["[active]|2026-01-15T06:00:00+00:00|never|new-job|0 6 * * *||"], NOW)
    assert fresh == 0 and late == [], (fresh, late)


@case("legacy 4-field line is still accepted")
def _():
    assert reasons("[active]|2026-01-15T06:30:00+00:00|2026-01-14T06:30:00+00:00|daily-report") == {}


@case("a separator inside the error message shifts nothing")
def _():
    m = reasons("[active]|2026-01-15T06:30:00+00:00|2026-01-14T06:30:00+00:00|X|30 6 * * *||error: a|b|c")
    assert "a|b|c" in m["X"], m


@case("deduced periods")
def _():
    assert ce.periode_s("every 30m") == 1800
    assert ce.periode_s("every 1440m") == 86400
    assert ce.periode_s("0 7 * * 1") == 7 * 86400
    assert ce.periode_s("30 6 * * *") == 86400
    assert ce.periode_s("0 4 2 * *") is None
    assert ce.periode_s("") is None


def age_since(y, mo, d, h, mi):
    return int((NOW - datetime.datetime(y, mo, d, h, mi, tzinfo=datetime.timezone.utc)).total_seconds())


@case("deliverable not rewritten despite an ok")
def _():
    m = reasons("[active]|2026-01-15T02:00:00+00:00|2026-01-14T02:01:23+00:00|nightly-consolidation|0 2 * * *|%d|ok"
                % age_since(2026, 1, 12, 2, 6))
    assert "deliverable" in m["nightly-consolidation"], m


@case("fresh deliverable: never shouts")
def _():
    assert reasons("[active]|2026-01-15T02:00:00+00:00|2026-01-14T02:01:23+00:00|nightly-consolidation|0 2 * * *|%d|ok"
                   % age_since(2026, 1, 14, 2, 21)) == {}


@case("deliverable late but under the grace: silence")
def _():
    assert reasons("[active]|2026-01-15T02:00:00+00:00|2026-01-14T02:01:23+00:00|nightly-consolidation|0 2 * * *|%d|ok"
                   % age_since(2026, 1, 14, 1, 1)) == {}


@case("failed age measurement: never shouts")
def _():
    assert reasons("[active]|2026-01-15T02:00:00+00:00|2026-01-14T02:01:23+00:00|nightly-consolidation|0 2 * * *|stat: no such file|ok") == {}


@case("declared deliverable missing on a job that already ran")
def _():
    m = reasons("[active]|2026-01-15T02:00:00+00:00|2026-01-14T02:01:23+00:00|nightly-consolidation|0 2 * * *|absent|ok")
    assert "not found" in m["nightly-consolidation"], m


@case("explicit failure wins over a frozen deliverable")
def _():
    m = reasons("[active]|2026-01-15T02:00:00+00:00|2026-01-14T02:01:23+00:00|nightly-consolidation|0 2 * * *|%d|error: HTTP 429"
                % age_since(2026, 1, 12, 2, 6))
    assert "429" in m["nightly-consolidation"], m


@case("job without a declared deliverable: empty field stays silent")
def _():
    assert reasons("[active]|2026-01-15T06:30:00+00:00|2026-01-14T06:30:00+00:00|daily-report|30 6 * * *||ok") == {}


def main():
    failures = 0
    for name, f in CASES:
        try:
            f()
            print("  ok   %s" % name)
        except AssertionError as e:
            failures += 1
            print("  FAIL %s\n        %s" % (name, e))
    print("\n%d cases, %d failure(s)" % (len(CASES), failures))
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
