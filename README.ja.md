<div align="center">

# self-evolve-harness

**ひとつの依頼を、検証できる変更へ。**

Claude Code・Codex・OpenCodeに、計画・分担・テスト・記憶を。

![Version](https://img.shields.io/badge/version-0.0.4-2563eb)
![Python](https://img.shields.io/badge/Python-3.11%2B-3776ab)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-475569)

[English](README.md) · **日本語**

</div>

## できること

<picture>
  <source media="(max-width: 600px)" srcset="docs/assets/workflow-ja-mobile.svg">
  <img src="docs/assets/workflow-ja.svg" alt="依頼 → 計画 → タスク定義に従って画面とAPIを分担 → テスト → 承認して適用" width="1120">
</picture>

| | やりたいこと | できること |
|---|---|---|
| ⚡ | いつものAI CLIですぐ直す | `/work`で必要なファイルを読み、実装・テスト。小さな修正に大きな計画書は不要 |
| 🧩 | 複数のAIに分担する | タスクごとにHost・Modelを指定。依存関係に沿って実行し、独立した作業は並列化 |
| ✅ | 結果を確かめて反映する | 作業用コピーでテスト・回数制限付き修正。検証済みの変更を承認して適用 |
| 💾 | 次の作業へ引き継ぐ | 知見を保存・検索。チェックポイントに目的・結果・次の作業を残して再開 |
| 🔬 | 開発手順そのものを改善する | Skill・プロンプトの候補を評価・比較してから採用。最適化は初期OFF |
| 🎛️ | プロジェクトに合わせる | 対話式セットアップでHost・Profile・Memory・コード解析・実行方式を選択 |

実際のAI実行はClaude Code・Codex・OpenCodeのCLI連携を使います。AGYは設定生成のみ対応。Engram・CodeGraph・Graphifyは別途導入が必要です。[対応範囲](docs/IMPLEMENTATION_MATRIX.md)

## 使い方

### 1 · インストール

Python **3.11以上**、macOS / Linuxで、このリポジトリ内から実行します。

```bash
make install
harness --version
# seh 0.0.4
```

`~/.local/bin`をPATHに追加すると、どのプロジェクトからでも利用できます。`harness`と`seh`は同じCLIです（既存の`seh`がある場合、`make install`は置き換えません）。AI作業には、使うHost CLIのインストール・認証も必要です。

### 2 · プロジェクトに適用

```bash
cd /path/to/project
harness apply
harness status
```

通常の対話ターミナルでは、設定を選んで差分を確認し、`y`で適用します。再実行すると既存の設定を引き継いで変更できます。

| 選ぶもの | 選択肢 |
|---|---|
| Host（複数可） | `claude` / `codex` / `opencode` / `agy` |
| Profile | `minimal` / `balanced` / `full` |
| Memory | `file` / `engram` |
| コード解析 | `none` / `codegraph` / `graphify` |
| 実行方式の既定 | `native` / `managed` |

日常作業には`balanced`が手軽です。Host選択は設定の生成先で、タスクごとのHost・Modelは別途指定できます。

```bash
harness apply --dry-run     # 書き込まず差分を確認
harness doctor             # CLI・連携設定を確認
harness rollback           # 最新の適用を元に戻す
```

適用後に編集されたファイルの巻き戻しは拒否します。[セットアップの詳細](docs/APPLY_CHOICES.ja.md)

### 3 · いつものAI CLIから依頼

対象プロジェクトでClaude Code・Codex・OpenCodeを起動して依頼します。

```text
/work タイムアウト値の入力チェックを追加して、関連テストを実行して
```

**普段はこれだけ。** 作業が大きくなったら、計画・分担・チェックポイントを使えます。

### 4 · ターミナルから計画・実装・テストを実行する

`harness work`は、**作業計画をJSONに保存し、その計画をAI CLIで実行するコマンド**です。対象プロジェクトのターミナルで使います。

| 使い方 | 入力する場所 | 向いている作業 |
|---|---|---|
| `/work 依頼内容` | AI CLIの会話欄 | 会話しながら修正する普段の開発 |
| `harness work …` | ターミナル | 計画・変更範囲・テストを決めて実行し、結果を確認して反映する作業 |

```text
plan → task.jsonを確認 → run → 結果・差分を確認 → resumeで適用
計画を作る                実装・テスト                 元のファイルへ反映
```

**① 依頼から計画を作る** — 以下は、CodexでPythonプロジェクトを修正する例です。

```bash
cd /path/to/project
harness work plan --goal 'タイムアウト値の入力チェックを追加' \
  --host codex --scope 'src/**,tests/**' --execute --out task.json
```

`--goal`が依頼内容、`--host`が使うAI CLI、`--scope`が変更を許可するパスです。`--execute`で計画作成のAI呼び出しを許可し、`--out`で計画を`task.json`に保存します。この段階では実装しません。

**② 計画とテストを確認する** — `task.json`を開き、各作業（`nodes`）の依頼内容・変更範囲を確認します。実装する作業の`checks`には、実際に使うテストコマンドを指定します。

```json
"checks": [["python3", "-m", "pytest", "-q"]]
```

これは`python3 -m pytest -q`を実行する指定です。Node.jsなら例として`[["npm", "test"]]`。生成された計画にテストが含まれるとは限らないので、実行前に確認してください。

**③ 計画を実行し、結果を見る**

```bash
harness work run --task task.json --host codex --trust-cli
```

作業用コピーで実装・テストを行い、結果をJSONで返します。**このコマンドでは元のソースファイルには反映しません。** `--trust-cli`は外部AI CLIの実行を許可する指定です。

出力された`run_id`を、以下の`<run-id>`に置き換えます。

```bash
harness work status <run-id>
```

`final_status`が`PASSED`、`applied`が`false`なら検証済み・未適用です。`changed_files`で変更対象を確認し、`.harness/state/runs/<run-id>/staging/`内のファイルと元のファイルを比較して内容をレビューします。

**④ 確認した変更を適用する**

```bash
harness work resume <run-id> --task task.json --host codex --trust-cli --apply --approve
```

`--apply`が反映、`--approve`が明示承認です。検証済みの変更を再実行せずに適用します。`task.json`は実行時の内容を維持してください。適用対象の元ファイルが途中で変わっていた場合は停止します。成功後は`applied`が`true`になります。

複数AIへの分担は、計画の各作業にHost・Model・依存関係を指定します。[Task JSON例](examples/multihost/task.json) · [Host・Modelの設定](docs/HOST_TASK_MODEL_UPDATES.md)

作業用コピーはOSサンドボックスではありません。[実行条件](docs/SECURITY.md)

### 5 · 知見を保存し、次の会話へ引き継ぐ

**繰り返し使う知見は`memory`、途中の作業の続きは`session`で保存します。** 以下は対象プロジェクトのターミナルで実行します。

| 残したいもの | 使うコマンド | 例 |
|---|---|---|
| 次回も役立つ知見 | `harness memory` | 「認証エラーでは有効期限を先に確認する」 |
| 今の作業の進捗 | `harness session` | 「入力検証は修正済み。次は関連テスト」 |

**知見を残す → 必要なときに検索する**

```bash
harness memory add '認証エラーでは有効期限を先に確認する'
harness memory search '認証'
```

`add`でメモを保存し、`search`で一致するメモをJSONで取得します。検索結果の`text`をAI CLIの会話に渡すと、次の作業で参照できます。`file`設定では`.harness/memory/items.json`に保存されます。

**作業を中断する → 次の会話で続ける**

① 会話を終える前に、目的・終わったこと・次にすることを保存します。

```bash
harness session checkpoint --task-id timeout-fix \
  --goal 'タイムアウト検証を追加' \
  --completed '入力検証を修正。テストは未実行' \
  --next '関連テストを実行し、差分を確認'
```

`timeout-fix`は自分で付ける作業名です。`.harness/memory/handoffs/timeout-fix.json`に保存され、同じ名前で保存すると最新版に置き換わります。会話全文ではなく、指定した要点を残します。

② 続けるときは、同じプロジェクトで作業名を指定します。

```bash
harness session resume timeout-fix --host codex
```

③ 出力JSONの`resume_prompt`を、同じプロジェクトで開いた新しいAI CLIの会話に貼り付けます。これが引き継ぎの入力です。`session resume`自体はAIを起動せず、実装も再開しません。

既存の会話をクリアして続ける場合も、まず保存成功を確認します。出力の`clear_command`を待機中のAI CLIに手動で入力し、その後`resume_prompt`を貼り付けてください。

`harness work run`では検証の区切りに自動保存されるため、作業名の代わりに`run_id`を使えます。**AIの会話への引き継ぎは`session resume`、計画に沿った実行・適用の再開は`work resume`です。** [引き継ぎの詳細](docs/CONTEXT_HANDOFF.ja.md)

### 6 · AI・APIなしで試す

このリポジトリ内で実行します。`mock`はオフライン動作確認用で、実際のAIは呼び出しません。

① サンプルを一時ディレクトリにコピーして、設定を生成します。

```bash
DEMO_ROOT=$(mktemp -d)
cp -R examples/demo_project/. "$DEMO_ROOT/"
python3 run_seh.py init --root "$DEMO_ROOT" --apply
```

② サンプルの作業計画を実行し、変更をその一時ディレクトリへ適用します。

```bash
python3 run_seh.py work run --root "$DEMO_ROOT" \
  --task "$DEMO_ROOT/work-task.json" --host mock --apply --approve
```

③ 評価を実行し、作業で作成されたファイルを確認します。

```bash
python3 run_seh.py eval run --root "$DEMO_ROOT" \
  --suite "$DEMO_ROOT/eval-suite.json" --host mock
cat "$DEMO_ROOT/result.txt"
```

`work run`の`final_status`が`PASSED`、`applied`が`true`、`eval run`の`all_passed`が`true`なら、サンプルの実行・適用・評価に成功しています。

すべての操作は`harness --help`から確認できます。[コマンド一覧](docs/COMMANDS.md) · [Host・Modelの設定](docs/HOST_TASK_MODEL_UPDATES.md)
