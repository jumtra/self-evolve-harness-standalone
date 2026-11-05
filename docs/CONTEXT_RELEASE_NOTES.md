# Context handoff update — changes on existing standalone core

- `/work` instructions: small changes skip ceremonial requirements/design/plan documents; medium tasks get brief inline planning only as needed.
- Task checkpoints: `seh session checkpoint`, `seh session status`, `seh session resume`.
- Interactive rotation: provide verified `/clear` or `/new` guidance and a compact, self-contained resume prompt. Do not claim to clear external terminal sessions programmatically.
- Managed DAG: checkpoint after each completed dependency wave and at termination; inject only the bounded handoff on `work resume`.
- Completion: `完了`, `検証完了（未適用）`, `比較実行完了（採用待ち）`, `未完了`.
- `work resume --apply --approve` can apply an already verified, unapplied staging run without re-executing the DAG, subject to the existing stale-base checks.
- Memory privacy: `handoffs/` ignored by Git; overwrite one small JSON per task, no transcripts.
- Fast path: no daemon, no extra model, no per-tool hook. Python remains harness implementation language; project source languages are not constrained.

## Upstream synchronization note

This patch was developed against the previously available 1.4.1 standalone source bundle, while the publicly visible repository `jumtra/self-evolve-harness-standalone` reports `0.0.2` on `main` (checked 2026-11-06). The key existing modules were inspected through GitHub raw source, but a complete git checkout could not be fetched in this environment. **Treat the supplied changes as a source patch, not a proven byte-for-byte clone of the latest main.** Run `git apply --check` on a clean clone before applying. No GitHub files or releases have been modified.
