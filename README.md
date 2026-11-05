<div align="center">

# self-evolve-harness

**One request. Changes you can verify.**

Connect Claude Code, Codex, and OpenCode with planning, task routing, tests, and approval.

**English** · [日本語](README.ja.md)

<sub>Python 3.11+ &nbsp; / &nbsp; macOS &amp; Linux &nbsp; / &nbsp; Optimization OFF by default</sub>

</div>

## What can it do?

<picture>
  <source media="(max-width: 600px)" srcset="docs/assets/workflow-en-mobile.svg">
  <img src="docs/assets/workflow-en.svg" alt="Request → Plan → Parallel UI work in Codex and API work in OpenCode → Tests → Approve and apply. Use /work for everyday tasks; evaluate and compare workflow improvements before adoption." width="1120">
</picture>

**Use `/work` for a quick fix. Add a plan and tests for larger changes. Evaluate workflow improvements before adopting them.**

| When you want to… | What you can do |
|---|---|
| Fix something in your usual AI CLI | Implement and test with `/work`, with no extra optimization calls |
| Split work across the UI and API | Select hosts and models per task; run independent tasks in parallel |
| Verify changes before applying them | Implement, test, and run bounded repairs in a working copy; explicitly approve applying changes |
| Reuse what worked | Save and search knowledge; evaluate and compare Skill/prompt changes before approved promotion |

<sub>The diagram illustrates routing defined in a task specification. Optimization is OFF by default. AGY supports configuration generation only.</sub>

## Usage

### 1. Install

Requires Python **3.11+** on macOS / Linux. Run from this repository's directory.

```bash
make install
harness --version
```

This links `~/.local/bin/harness` (and `~/.local/bin/seh` if not already present) so you can run `harness` from any directory without activating a virtual environment.

To install as an editable Python package in a virtual environment instead:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -e .
harness --version
```

To try without installing, replace `harness` / `seh` with `python3 run_seh.py`. Real AI work also requires an installed and authenticated Claude Code, Codex, or OpenCode CLI.

### 2. Set up a project

Replace `/path/to/project` with your project path. Set `--hosts` to the hosts you use (for example, `claude,codex,opencode`).

```bash
# Preview generated files and changes
seh init --root /path/to/project --hosts codex --profile balanced

# Generate configuration and check setup
seh init --root /path/to/project --hosts codex --profile balanced --apply
seh doctor --root /path/to/project
```

The `balanced` profile generates two Skills (`harness-init`, `work`) and four Agent definitions per host.

### 3. Everyday development

Start your AI CLI in the target project and ask `/work` to do the task.

```text
/work Add timeout input validation and run the relevant tests
```

### 4. Run with a plan and tests

This example uses Codex. You can change `--host` to `claude` or `opencode`.

```bash
cd /path/to/project

# Generate a task plan
seh work plan --root . --goal 'Add timeout input validation' \
  --host codex --scope 'src/**,tests/**' --execute --out task.json

# Review task.json and set checks to your project's test commands before running
seh work run --root . --task task.json --host codex --trust-cli

# Inspect results using the run_id from the output
seh work status <run-id> --root .

# After reviewing the plan and results, rerun and apply successful changes
seh work run --root . --task task.json --host codex --trust-cli --apply --approve
```

Adjust `--scope` and tests to your project. The [Task JSON example](examples/multihost/task.json) shows hosts, models, tests, and dependencies.

`--trust-cli` permits external CLI execution. Working copies are not OS sandboxes. See [security](docs/SECURITY.md) for execution requirements.

### 5. Try without AI or an API

Run from this repository's directory.

```bash
# Copy the demo to a temporary directory
DEMO_ROOT=$(mktemp -d)
cp -R examples/demo_project/. "$DEMO_ROOT/"

python3 run_seh.py init --root "$DEMO_ROOT" --apply
python3 run_seh.py work run --root "$DEMO_ROOT" \
  --task "$DEMO_ROOT/work-task.json" --host mock --apply --approve
python3 run_seh.py eval run --root "$DEMO_ROOT" \
  --suite "$DEMO_ROOT/eval-suite.json" --host mock
cat "$DEMO_ROOT/result.txt"
```

`mock` is a deterministic offline test driver, not an AI model.

### Other operations

| Action | Command |
|---|---|
| Preview and sync configuration | `seh sync --root .` → `seh sync --root . --apply` |
| Save and search notes | `seh memory add 'Check auth expiry first' --root .` / `seh memory search 'auth' --root .` |
| Search code | `seh code search 'timeout' --root .` |
| Lint Skills | `seh author lint --root .` |
| Check optimization status | `seh optimize status --root .` |
| Refresh CLI compatibility information | `seh hosts refresh` |
| Refresh model information | `seh models refresh --host opencode` |
| See all options | `seh --help` / `seh work run --help` |

Details: [Capabilities](docs/IMPLEMENTATION_MATRIX.md) · [Hosts, models & updates](docs/HOST_TASK_MODEL_UPDATES.md) · [Compatibility & limitations](docs/COMPATIBILITY.md)
