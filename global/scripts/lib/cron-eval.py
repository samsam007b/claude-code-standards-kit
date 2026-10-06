#!/usr/bin/env python3
"""
cron-eval.py: classify scheduler jobs as fresh / late, from a listing of the scheduler.

Use it to cross-check any scheduler that can list its jobs with next run, last run, last
status and schedule (an agent scheduler, a cron wrapper, a CI runner). The logic lives in
a Python module, not inline in shell, so it can be tested: a rule that was wrong once and
cannot be tested is the last thing to leave without a safety net.

Input on stdin, one line per job:
    state|next|last|name|schedule|artifact_age|status
`status` is the LAST field because it absorbs everything after it: an error message may
contain anything, separator included. Lines with only the first four fields are accepted.
  state         contains "active" for a live job (anything else = paused/disabled)
  next, last    ISO-8601 timestamps with offset ("never" or garbage = not usable)
  schedule      "every Nm" or a 5-field cron expression (used only when unambiguous)
  artifact_age  seconds since the job's deliverable file was last written, "absent", or empty
  status        "ok" or "error: <reason>"
Output on stdout: fresh count, then anomaly count, then one `name|hours|reason` line each.

Environment: GRACE_H (default 2) tolerance in hours;
             CRON_EVAL_WATCHERS comma-separated job names or suffixes that are themselves
             monitors (default "-watchdog").

Five failure shapes this evaluator learned the hard way, each one a question the previous
version forgot to ask:
  1. "is it running"               -> fixed threshold: flagged every healthy job
  2. "is it recent"                -> too coarse
  3. "is the next slot in future"  -> a stuck scheduler is caught, but not the cases below
  4. "did the last run succeed"    -> an `ok` only means "the session ended without exception"
  5. "did it write its deliverable" -> a model that returns an empty page ends cleanly
A healthy scheduler that fires jobs which all fail is, from the outcome's side, a dead one.
"""
import datetime
import os
import re
import sys


def periode_s(schedule):
    """Nominal period of a job in seconds, or None at the slightest doubt.

    Only used to detect a slot consumed without an execution: `next` advanced one step while
    `last` stayed one step behind. Only two unambiguous forms are deduced: `every Nm` and a
    cron expression with a single day. An hour list (`0 8,15 * * *`) makes the real period
    shorter than the retained value, so the last run looks more recent than the expected
    minimum: the error goes toward silence, never toward a false positive.
    """
    schedule = (schedule or "").strip()
    m = re.fullmatch(r"every (\d+)m", schedule)
    if m:
        return int(m.group(1)) * 60
    fields = schedule.split()
    if len(fields) == 5:
        _, _, day_of_month, month, day_of_week = fields
        if day_of_month == "*" and month == "*":
            if day_of_week == "*":
                return 86400
            if re.fullmatch(r"[0-6]", day_of_week):
                return 7 * 86400
    return None


def est_surveillance(name):
    """Jobs whose pause IS the failure: monitors.

    A job disabled by hand is not an outage, except for a monitor: a paused watchdog reports
    nothing and does not report that it reports nothing. Matched by suffix so a future
    monitor is covered without anyone remembering to list it.
    """
    watchers = [w.strip() for w in os.environ.get("CRON_EVAL_WATCHERS", "-watchdog").split(",") if w.strip()]
    for w in watchers:
        if w.startswith("-") and name.endswith(w):
            return True
        if name == w:
            return True
    return False


def evaluer(lines, now, grace_h=2.0):
    fresh, late = 0, []
    for line in lines:
        fields = line.rstrip("\n").split("|", 6)
        if len(fields) < 4:
            continue
        state, nxt, last, name = fields[:4]
        schedule = fields[4] if len(fields) > 4 else ""
        artifact = fields[5] if len(fields) > 5 else ""
        status = fields[6] if len(fields) > 6 else ""

        if "active" not in state:
            if est_surveillance(name):
                late.append((name, 0, "PAUSED, no more monitoring"))
            continue

        try:
            d = datetime.datetime.fromisoformat(last)
            if (now - d).total_seconds() / 3600 <= 26:
                fresh += 1
        except ValueError:
            # A never-run job has no usable timestamp: neither fresh nor late (a new job).
            pass

        # Core rule: a next slot in the past is the one proof of a stuck scheduler valid for
        # every periodicity at once, daily to monthly, with no period table to maintain.
        try:
            s = datetime.datetime.fromisoformat(nxt)
        except ValueError:
            continue
        late_h = (now - s).total_seconds() / 3600
        if late_h > grace_h:
            late.append((name, int(late_h), "slot overdue by %d h" % late_h))
            continue

        # Did the last run succeed.
        if status.startswith("error"):
            reason = status[len("error:"):].strip() or "no reason published"
            late.append((name, 0, "last run failed: " + reason[:120]))
            continue

        # Did the job write its deliverable. The scheduler's `ok` says nothing about content,
        # only the file date does: a file older than the last run was not written by it.
        # Deliberate silence on: empty field (no deliverable declared), non-numeric field (the
        # probe failed to measure, and a failed measurement must never shout), never-run job.
        # Never alarm on the length of the reply: an empty reply is a legitimate state for
        # jobs that only report; the contract that matters is "this job produces a file".
        if artifact and artifact != "absent":
            try:
                age_art = float(artifact)
                d_art = datetime.datetime.fromisoformat(last)
            except ValueError:
                age_art = None
            if age_art is not None:
                written = now - datetime.timedelta(seconds=age_art)
                gap_h = (d_art - written).total_seconds() / 3600
                if gap_h > grace_h:
                    late.append((name, int(gap_h),
                                 "ran on %s without rewriting its deliverable, frozen at %s"
                                 % (d_art.strftime("%d/%m %Hh%M"), written.strftime("%d/%m %Hh%M"))))
                    continue
        elif artifact == "absent":
            try:
                datetime.datetime.fromisoformat(last)
            except ValueError:
                pass
            else:
                late.append((name, 0, "expected deliverable not found"))
                continue

        # A slot consumed without an execution (see periode_s).
        p = periode_s(schedule)
        if p is not None:
            try:
                d = datetime.datetime.fromisoformat(last)
            except ValueError:
                continue
            expected = s - datetime.timedelta(seconds=p)
            missed_h = (expected - d).total_seconds() / 3600
            if missed_h > grace_h:
                late.append((name, int(missed_h),
                             "slot of %s consumed without execution, last run %s"
                             % (expected.strftime("%d/%m %Hh%M"), d.strftime("%d/%m %Hh%M"))))

    # Monitor pauses first (their age cannot be deduced), then by decreasing lateness.
    return fresh, sorted(late, key=lambda x: (x[2].startswith("slot"), -x[1]))


def main():
    grace = float(os.environ.get("GRACE_H", 2))
    now = datetime.datetime.now(datetime.timezone.utc)
    fresh, late = evaluer(sys.stdin, now, grace)
    print(fresh)
    print(len(late))
    for name, h, reason in late:
        print("%s|%d|%s" % (name, h, reason))


if __name__ == "__main__":
    main()
