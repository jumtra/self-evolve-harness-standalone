# v0.0.4: `harness apply` 実装・運用仕様

## ライフサイクル

`harness update`（CLI本体の更新）→ `cd <project>` → `harness apply --dry-run` → `harness apply` → `harness status` が基本です。`harness apply`は通常のターミナルでは選択画面を表示します（CI・パイプラインでは非対話。詳細は[こちら](APPLY_CHOICES.ja.md)）。`harness apply`はCWDを`Path.resolve()`で解釈し、`--root`指定時だけ対象を変更します。更新は初回・既存共通で、言語・フレームワークは限定しません。

| コマンド | 副作用 | 結果 |
|---|---|---|
| `harness apply --dry-run` | なし（読み取り専用） | 計画内容・差分件数の表示 |
| `harness apply` | ファイル作成・更新、スナップショット保存 | ハーネス設定・プロファイル適用 |
| `harness apply --check` | なし | 差分なし=0、差分あり=5、衝突=4 |
| `harness status` | なし | 導入バージョン・ドリフト状況 |
| `harness rollback` | 最新スナップショットへ巻き戻し | 適用前の状態を復元 |
