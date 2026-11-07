<div align="center">

# self-evolve-harness

**One request. Changes you can verify.**

Bring planning, task routing, tests, and memory to Claude Code, Codex, and OpenCode.

![Version](https://img.shields.io/badge/version-0.0.4-2563eb)
![Python](https://img.shields.io/badge/Python-3.11%2B-3776ab)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-475569)

**English** · [日本語](README.ja.md)

</div>

## What you can do

<picture>
  <source media="(max-width: 600px)" srcset="docs/assets/workflow-en-mobile.svg">
  <img src="docs/assets/workflow-en.svg" alt="Request → Plan → Split UI and API work using a task specification → Tests → Approve and apply" width="1120">
</picture>

| | Your goal | What you can do |
|---|---|---|
| ⚡ | Fix something in your usual AI CLI | Use `/work` to read relevant files, implement, and test. Small fixes need no lengthy planning documents |
| 🧩 | Share work across AI clients | Choose hosts and models per task. Respect dependencies and run independent tasks in parallel |
| ✅ | Verify before applying | Test and run bounded repairs in a working copy, then approve applying verified changes |
| 💾 | Pick up where you left off | Save and search knowledge. Resume from checkpoints with goals, results, and next steps |
| 🔬 | Improve your development workflow | Evaluate and compare Skill/prompt candidates before adoption. Optimization starts OFF |
| 🎛️ | Fit your project | Choose hosts, profile, memory, code intelligence, and runtime through interactive setup |

AI execution uses the Claude Code, Codex, and OpenCode CLIs. AGY supports configuration generation only. Engram, CodeGraph, and Graphify require separate setup. [Supported capabilities](docs/IMPLEMENTATION_MATRIX.md)

## Usage

### 1 · Install

Requires Python **3.11+** on macOS / Linux. Run inside this repository.

```bash
make install
harness --version
# seh 0.0.4
```

Add `~/.local/bin` to PATH to use the CLI from any project. `harness` and `seh` are the same CLI (`make install` preserves an existing `seh` command). AI work also requires installing and authenticating your chosen host CLI.

### 2 · Apply to a project

```bash
cd /path/to/project
harness apply
harness status
```

In a regular interactive terminal, choose settings, review the changes, and enter `y` to apply. Run again to adjust the existing configuration.

| Setting | Choices |
|---|---|
| Hosts (multiple allowed) | `claude` / `codex` / `opencode` / `agy` |
| Profile | `minimal` / `balanced` / `full` |
| Memory | `file` / `engram` |
| Code intelligence | `none` / `codegraph` / `graphify` |
| Default runtime | `native` / `managed` |

Start with `balanced` for everyday work. Host selection controls where configuration is generated; task hosts and models can be chosen separately.

```bash
harness apply --dry-run     # Preview without writing
harness doctor             # Check CLIs and integration setup
harness rollback           # Undo the latest application
```

Rollback refuses to overwrite files edited after application. [Setup details (Japanese)](docs/APPLY_CHOICES.ja.md)

### 3 · Ask your usual AI CLI

Start Claude Code, Codex, or OpenCode in your project and ask:

```text
/work Add timeout input validation and run the relevant tests
```

**That's the everyday workflow.** Add a plan, task routing, or checkpoints as the work grows.

### 4 · Plan, implement, and test from the terminal

`harness work` **saves a plan as JSON and runs that plan through an AI CLI**. Use it in your project's terminal.

| Interface | Where to type | When to use it |
|---|---|---|
| `/work your request` | Your AI CLI conversation | Everyday changes with conversational guidance |
| `harness work …` | Your terminal | Run a reviewed plan with explicit scope and tests, then inspect and apply the result |

```text
plan → review task.json → run → review results and changes → resume to apply
create a plan            implement and test                  update source files
```

**① Create a plan** — This example uses Codex to change a Python project.

```bash
cd /path/to/project
harness work plan --goal 'Add timeout input validation' \
  --host codex --scope 'src/**,tests/**' --execute --out task.json
```

`--goal` is your request, `--host` chooses the AI CLI, and `--scope` lists allowed write paths. `--execute` permits the AI planning call; `--out` saves the plan to `task.json`. This step does not implement the change.

**② Review the plan and tests** — Open `task.json` and review each task's (`nodes`) instructions and write scope. Set `checks` on implementation tasks to your actual test command.

```json
"checks": [["python3", "-m", "pytest", "-q"]]
```

This runs `python3 -m pytest -q`. For Node.js, an example is `[["npm", "test"]]`. Generated plans may omit tests, so check before running.

**③ Run the plan and inspect the result**

```bash
harness work run --task task.json --host codex --trust-cli
```

This implements and tests in a working copy and returns JSON results. **This command leaves the original source files unapplied.** `--trust-cli` permits external AI CLI execution.

Replace `<run-id>` below with the `run_id` returned by the command.

```bash
harness work status <run-id>
```

`final_status: PASSED` with `applied: false` means verified but unapplied. Check `changed_files`, then review the changes by comparing files under `.harness/state/runs/<run-id>/staging/` with the originals.

**④ Apply the changes you reviewed**

```bash
harness work resume <run-id> --task task.json --host codex --trust-cli --apply --approve
```

`--apply` requests application; `--approve` explicitly approves it. Verified changes are applied without rerunning the work. Keep `task.json` unchanged from the run. Application stops if the original files being changed have drifted. After success, `applied` becomes `true`.

To split work across AI clients, assign hosts, models, and dependencies to individual tasks. [Task JSON example](examples/multihost/task.json) · [Host and model configuration](docs/HOST_TASK_MODEL_UPDATES.md)

Working copies are not OS sandboxes. [Execution requirements](docs/SECURITY.md)

### 5 · Save knowledge and hand off work

**Use `memory` for reusable knowledge and `session` to pick up unfinished work.** Run the following commands in your project's terminal.

| What to save | Command | Example |
|---|---|---|
| Knowledge for future tasks | `harness memory` | “Check expiry first when authentication fails” |
| Progress on the current task | `harness session` | “Validation updated; relevant tests are next” |

**Save a note → Find it when you need it**

```bash
harness memory add 'Check expiry first when authentication fails'
harness memory search 'authentication'
```

`add` saves the note; `search` returns matching notes as JSON. Pass the result's `text` to your AI CLI conversation to use it in a later task. With the `file` provider, notes live in `.harness/memory/items.json`.

**Pause a task → Continue in the next conversation**

① Before ending the conversation, save the goal, progress, and next steps.

```bash
harness session checkpoint --task-id timeout-fix \
  --goal 'Add timeout validation' \
  --completed 'Updated input validation; tests not yet run' \
  --next 'Run relevant tests and review the diff'
```

`timeout-fix` is a task name you choose. This saves `.harness/memory/handoffs/timeout-fix.json`. Saving under the same name replaces it with the latest checkpoint. It stores the details you supply, rather than the conversation transcript.

② When ready to continue, use that task name in the same project.

```bash
harness session resume timeout-fix --host codex
```

③ Copy `resume_prompt` from the JSON output into a new AI CLI conversation opened in the same project. This is the handoff input. `session resume` itself does not launch the AI or resume implementation.

To continue by clearing an existing conversation, first confirm the checkpoint was saved. Manually enter the returned `clear_command` in your idle AI CLI, then paste `resume_prompt`.

`harness work run` saves checkpoints automatically at validation boundaries, so you can use its `run_id` as the task name. **Use `session resume` to hand off to an AI conversation; use `work resume` to resume planned execution or application.** [Handoff details (Japanese)](docs/CONTEXT_HANDOFF.ja.md)

### 6 · Try without AI or an API

Run inside this repository. `mock` is an offline test driver and does not call a real AI.

① Copy the demo into a temporary directory and generate its configuration.

```bash
DEMO_ROOT=$(mktemp -d)
cp -R examples/demo_project/. "$DEMO_ROOT/"
python3 run_seh.py init --root "$DEMO_ROOT" --apply
```

② Run the sample task plan and apply its changes to that temporary directory.

```bash
python3 run_seh.py work run --root "$DEMO_ROOT" \
  --task "$DEMO_ROOT/work-task.json" --host mock --apply --approve
```

③ Run the evaluation and inspect the file created by the task.

```bash
python3 run_seh.py eval run --root "$DEMO_ROOT" \
  --suite "$DEMO_ROOT/eval-suite.json" --host mock
cat "$DEMO_ROOT/result.txt"
```

The demo succeeds when `work run` returns `final_status: PASSED` and `applied: true`, and `eval run` returns `all_passed: true`.

Explore all operations with `harness --help`. [Command index](docs/COMMANDS.md) · [Host and model configuration](docs/HOST_TASK_MODEL_UPDATES.md)
