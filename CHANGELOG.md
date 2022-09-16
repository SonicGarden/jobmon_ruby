## 1.2.3

- Fix generator

## 1.2.2

- Add `jobmon:good_job_queue_monitor` task

## 1.2.1

- `jobmon:send_healthcheck_mail` taskで送信されるメールに本文設定

## 1.2.0

- deprecated: Jobmon::Configuration#available_release_stagings (代わりに Jobmon::Configuration#available_release_stages を使う)
- 明示的に release_stage を設定可能 (Jobmon::Configuration#release_stage=)

## 1.1.0

- Add `jobmon:send_healthcheck_mail task`

## 1.0.0

- ジョブが失敗した場合にエラー終了して記録するように
- 二重リクエスト対策
- Drop support faraday v1

## 0.8.3

- faraday_middlewareを依存から削除

## 0.8.0

- ジョブの開始・終了時間を送信するように

## 0.7.0

- jobmon:delayed_job_queue_monitorタスクでは遅延件数のみカウントするように

## 0.6.1

- ログを残すように対応

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
