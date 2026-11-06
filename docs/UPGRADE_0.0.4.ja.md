# v0.0.4 への導入・差分更新

## 新規導入・現行版の置き換え（推奨）

このリリースでは、Python 3.11以上で利用できる単体のスタンドアロンCLIパッケージです。ユーザープロジェクトを上書きする前に、適用内容を選択・確認できます。

```bash
harness --version
cd /path/to/project
harness apply                     # 通常の対話ターミナルでは選択式
harness apply --dry-run           # 書き込まないプレビュー
harness status
```

## 自動化・性能

`harness apply --non-interactive`、`harness apply --hosts claude,codex --profile balanced`など、明示フラグ付きの実行は質問しません。CIでは`--check`を使用してください。`harness apply --interactive`は入力がパイプ経由でも明示的に対話できます。通常のTask実行ではウィザードを起動しません。

なお**Hostの選択は設定ファイル生成先の選択**です。タスクごとのHostとModelは、従来のTaskSpecと実行オプションで変更できます。外部のCodeGraph/Graphify/Engramや各ホストCLIは、選択画面で選んでも自動インストールされません。
