# CLAUDE.md

Jobmon: Railsアプリのバッチ処理・ジョブ実行を監視し、外部のJobmonWebサービスに開始/終了/失敗を通知するgem。

## コマンド

```bash
bundle exec rspec   # テスト実行（rake spec でも可、デフォルトタスク）
```

lintは未導入（.rubocop.yml なし、Gemfile.lockにrubocop系gemなし）。

## アーキテクチャ

- `lib/jobmon.rb` — configure/available?/with_options。設定は `Jobmon::Configuration`（`lib/jobmon/configuration.rb`）
- `lib/jobmon/client.rb` — 監視の中核。`job_monitor` でブロック実行を開始/終了ログ＋HTTP通知でラップ
- `lib/jobmon/cli.rb` + `exe/jobmon` — CLI実行（`--cmd` または rakeタスク名）
- `lib/jobmon/active_job_extension.rb` — ActiveJob向けConcern（`jobmon_with(name:, estimate_time:)`）
- `lib/jobmon/engine.rb` — Rails::Engine。`app/jobs`, `app/mailers`, `lib/tasks/*.rake` をホストアプリに自動読込
- `lib/generators/jobmon/jobmon_generator.rb` — `rails g jobmon` 用。templates/ ディレクトリは存在せず、initializer内容はヒアドキュメント直書き

## Gotchas

- `exe/jobmon` はgem単体では動かない。実行時カレントディレクトリの `config/environment.rb`（ホストRailsアプリ）に依存する
- `spec/spec_helper.rb` のグローバル `before` フックが `Jobmon.available?` を常に `true` にスタブする。`available?` 自体や有効/無効の分岐をテストする場合は `no_jobmon_mock: true` メタデータを付与すること
- Rake実行時の例外は `SystemExit` になる（Rakeの挙動）。`cli.rb`/`client.rb` では `rescue SystemExit, StandardError` で明示的にハンドリングしている
- `--task` CLIオプションは廃止済みだが引数としては残っており、指定すると `ArgumentError` を送出する（後方互換のための明示的エラー）
- CHANGELOG.md は運用終了。実際の変更履歴は [GitHub Releases](https://github.com/SonicGarden/jobmon_ruby/releases) を参照
- CIは `.github/workflows/rspec.yml` でRuby 3.2/3.3/3.4のマトリクスのみ実行（rubocopジョブなし）
