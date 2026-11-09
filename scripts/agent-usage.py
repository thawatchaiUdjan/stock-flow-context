"""Summarise Codex per-response usage without inherited-history double counting."""

import argparse
import glob
import json
import re
from collections import Counter
from datetime import datetime
from pathlib import Path

FIELDS = ("input_tokens", "cached_input_tokens", "output_tokens", "reasoning_output_tokens")


def instant(value):
    parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    if parsed.tzinfo is None:
        raise ValueError("timestamps must include a timezone")
    return parsed


def summarise(paths, until=None):
    seen = {}
    threads = {}
    unknown = []
    for path in dict.fromkeys(map(Path, paths)):
        match = re.search(r"([0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12})$", path.stem)
        if not match:
            unknown.append({"file": path.name, "reason": "filename has no thread UUID"})
            continue
        thread = match[1]
        supported = False
        for line in path.read_text(encoding="utf-8").splitlines():
            event = json.loads(line)
            if event.get("type") != "token_usage_record":
                continue
            item = event.get("payload", {})
            if item.get("thread_id") != thread:
                continue
            if until and instant(event["timestamp"]) > until:
                continue
            usage = item.get("usage", {})
            response = item.get("response_id")
            if not response or any(type(usage.get(k)) is not int for k in FIELDS):
                raise ValueError(f"{path.name}: incomplete per-response usage")
            if any(usage[k] < 0 for k in FIELDS):
                raise ValueError(f"{path.name}: negative usage")
            if usage["cached_input_tokens"] > usage["input_tokens"] or usage["reasoning_output_tokens"] > usage["output_tokens"]:
                raise ValueError(f"{path.name}: invalid token subsets")
            counts = {k: usage[k] for k in FIELDS}
            supported = True
            if response in seen:
                if seen[response] != (thread, counts):
                    raise ValueError(f"{path.name}: conflicting duplicate response")
                continue
            seen[response] = (thread, counts)
            stats = threads.setdefault(thread, Counter())
            stats.update(counts)
            stats["requests"] += 1
        if not supported:
            unknown.append({"file": path.name, "reason": "no own-thread usage in selected range"})

    totals = Counter()
    for stats in threads.values():
        stats["uncached_input_tokens"] = stats["input_tokens"] - stats["cached_input_tokens"]
        stats["total_tokens"] = stats["input_tokens"] + stats["output_tokens"]
        totals.update(stats)
    return {"threads": threads, "totals": totals if threads else None, "unknown": unknown,
            "note": "Recorded usage only; cached/reasoning are subsets, not extra tokens. No billing estimate."}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("files", nargs="+", help="Codex rollout paths or glob patterns")
    parser.add_argument("--until", type=instant, help="Inclusive timezone-qualified ISO timestamp")
    args = parser.parse_args()
    paths = []
    for pattern in args.files:
        matches = glob.glob(pattern)
        if not matches:
            parser.error(f"no logs match: {pattern}")
        paths.extend(matches)
    try:
        report = summarise(paths, args.until)
    except (OSError, ValueError, KeyError) as error:
        parser.error(str(error))
    print(json.dumps(report, indent=2))
    return 1 if report["unknown"] or report["totals"] is None else 0


if __name__ == "__main__":
    raise SystemExit(main())
