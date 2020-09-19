## 0.6.0

- ActiveJobの起動確認に対応

## 0.5.2

- jobmonサーバに対するリクエストのリトライ対応

## 0.5.0

- `jobmon` DSL を削除
- `jobmon` コマンドの `--task` オプションを削除
- `task_with_monitor` DSL を削除

## 0.4.4

- 接続エラー時には`Jobmon::RequestError`を投げるように

## 0.4.3

- `jobmon` コマンドの `--task` オプションを非推奨に
- `jobmon` コマンドに `--cmd` オプションを追加

## 0.4.2

- `endpoint` オプション追加
- `hostname` オプション追加
- `jobmon` DSL を非推奨に
- rake タスクの環境変数引数に対応

## 0.4.1

- 引数付きタスクに対応

## 0.4.0

- `jobmon`コマンド追加
- `task_with_monitor` DSL を非推奨に
- `jobmon:test_job` タスク削除
- `skip_jobmon_available_check` オプション削除

## 0.3.0

- `estimate_time` のデフォルト設定をサポート
- jobmon DSL を追加
- 引数付きタスクをサポート
