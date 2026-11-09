import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location("agent_usage", Path(__file__).with_name("agent-usage.py"))
usage = importlib.util.module_from_spec(spec)
spec.loader.exec_module(usage)
THREAD = "00000000-0000-0000-0000-000000000001"
OTHER = "00000000-0000-0000-0000-000000000002"


def record(response, thread=THREAD, timestamp="2026-11-09T08:00:00Z"):
    return {"type": "token_usage_record", "timestamp": timestamp, "payload": {
        "thread_id": thread, "response_id": response, "usage": {
            "input_tokens": 100, "cached_input_tokens": 80,
            "output_tokens": 10, "reasoning_output_tokens": 4}}}


class UsageTests(unittest.TestCase):
    def report(self, events, until=None, twice=False):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / f"rollout-{THREAD}.jsonl"
            path.write_text("\n".join(json.dumps(e) for e in events), encoding="utf-8")
            return usage.summarise([path, path] if twice else [path], until)

    def test_excludes_inherited_records_and_deduplicates_responses_and_files(self):
        report = self.report([record("a", OTHER), record("b"), record("b")], twice=True)
        self.assertEqual(report["totals"]["requests"], 1)
        self.assertEqual(report["totals"]["total_tokens"], 110)
        self.assertEqual(report["totals"]["uncached_input_tokens"], 20)
        self.assertEqual(report["totals"]["reasoning_output_tokens"], 4)

    def test_cutoff_excludes_later_audit(self):
        report = self.report([record("a"), record("b", timestamp="2026-11-09T09:00:00Z")],
                             usage.instant("2026-11-09T08:30:00Z"))
        self.assertEqual(report["totals"]["requests"], 1)

    def test_missing_usage_is_unknown_not_zero(self):
        report = self.report([{"type": "session_meta", "payload": {}}])
        self.assertIsNone(report["totals"])
        self.assertEqual(len(report["unknown"]), 1)

    def test_incomplete_and_conflicting_usage_fail(self):
        incomplete = record("a")
        del incomplete["payload"]["usage"]["cached_input_tokens"]
        with self.assertRaises(ValueError):
            self.report([incomplete])
        changed = record("a")
        changed["payload"]["usage"]["input_tokens"] = 101
        with self.assertRaises(ValueError):
            self.report([record("a"), changed])

    def test_naive_timestamp_is_rejected(self):
        with self.assertRaises(ValueError):
            usage.instant("2026-11-09T08:30:00")


if __name__ == "__main__":
    unittest.main()
