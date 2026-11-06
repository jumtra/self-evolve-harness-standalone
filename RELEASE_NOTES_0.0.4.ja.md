# v0.0.4 — 対話式 `harness apply`

- **追加**: 通常のTTYで`harness apply`すると選択式ウィザードを表示。Profile・複数Host・CodeGraph/Graphify/None・Memory・Runtime・テスト候補検出を選択。
- **追加**: 差分・ファイル一覧の確認と、**デフォルトNo**の明示承認。中止しても変更なし。
- **追加**: `--interactive` / `--non-interactive` / `--runtime`。他の明示フラグがあれば標準のウィザードはスキップ。
- **維持**: `--dry-run`、`--check`、所有権保護、バックアップ、`rollback`、非TTYでの自動化、標準出力JSON。
- **設計上の区別**: 適用Hostは設定の生成先。実行Host・ModelはTask/Node単位で選択。
- **性能**: 選択処理にはネットワーク、SDK、LLMの追加呼び出しなし。通常Workパスは影響なし。

詳細: [docs/APPLY_CHOICES.ja.md](docs/APPLY_CHOICES.ja.md)
