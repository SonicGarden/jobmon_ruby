---
name: ruby-rails-ci-matrix
description: "Ruby gem の CI でテストする Ruby・Rails のバージョンマトリクスを保守する。EOL になったバージョンの除外、サポート中の最新バージョンの追加、それに伴う gemfiles・gemspec の更新を行うときに使う。「サポート切れの Ruby/Rails を外したい」「最新の Rails を追加したい」「CI マトリクスを更新したい」といった依頼で必ず使う。"
license: MIT
---

# ruby-rails-ci-matrix

複数 Rails バージョンを CI でテストする Ruby gem（GitHub Actions のマトリクス ＋
`gemfiles/railsXX.gemfile` ＋ gemspec を持つ構成）で、テスト対象の Ruby・Rails
バージョンを最新のサポート状況に合わせて保守する手順。

EOL（End of Life）になったバージョンを除外し、サポート中＋最新版を追加する。
gemfile・gemspec・ワークフロー YAML は**対で**更新しないと CI が壊れるため、
すべてを一貫させることが肝。

## 1. 現状把握

更新前に、関係する 3 種類のファイルを必ず読む。

| ファイル | 見るところ |
| --- | --- |
| `.github/workflows/*.yml` | `strategy.matrix.include` の `{ ruby:, gemfile: }` エントリ一覧、`ruby/setup-ruby` のバージョン |
| `gemfiles/*.gemfile` | 各 Rails バージョン用 gemfile。`source` URL と `gem 'rails', '~> X.Y.0'` |
| `*.gemspec` | `required_ruby_version` と `add_dependency "rails", ...` の下限 |

マトリクスの `gemfile:` の値と `gemfiles/<値>.gemfile` は 1:1 で対応している点を押さえる。

## 2. EOL 調査

**今日の日付を基準に**サポート状況を調べる。必ず最新情報を取得すること（記憶に頼らない）。

- Ruby: <https://endoflife.date/ruby>
- Rails: <https://endoflife.date/rails>

endoflife.date が読めない場合は WebSearch で代替する。確認するのは次の 3 点:

1. 各バージョンの EOL 日付（セキュリティサポート終了日を含む）→ 今日時点で切れているか
2. 現在サポート中のバージョン一覧
3. 最新の安定版（新メジャー、例 Ruby 4.0 / Rails 8.1 などが出ていないか）

> Ruby は毎年 12 月に新バージョン、サポートは約 3 年 3 ヶ月。Rails 7.2 以降は
> 通常サポート 1 年・セキュリティサポート 2 年。

## 3. 対象の決定

- **除外**: 今日時点で EOL（セキュリティサポートも終了）の Ruby / Rails。
- **追加**: サポート中で未掲載のバージョン ＋ 最新安定版。
- **残す判断**: セキュリティサポート中なら残してよい。ただし数ヶ月内に切れるものは
  ユーザーに残すか確認するとよい。
- マトリクスは **各 Rails バージョン × 対応する Ruby バージョン**の組み合わせで作る。
  古い Rails ほど新しい Ruby を載せないなど、互換性に注意。

## 4. ファイル更新

3 ファイルを一貫させる。**gemfile を消したらマトリクスからも消す**（逆も同様）。

### ワークフロー YAML のマトリクス

`include:` のエントリを更新。Ruby は短縮指定（`"4.0"`）にすると `ruby/setup-ruby`
が最新パッチを自動選択する。

```yaml
strategy:
  matrix:
    include:
      - { ruby: "3.3", gemfile: "rails72" }
      - { ruby: "3.4", gemfile: "rails72" }
      - { ruby: "4.0", gemfile: "rails72" }
      - { ruby: "3.3", gemfile: "rails80" }
      - { ruby: "3.4", gemfile: "rails80" }
      - { ruby: "4.0", gemfile: "rails80" }
      - { ruby: "3.3", gemfile: "rails81" }
      - { ruby: "3.4", gemfile: "rails81" }
      - { ruby: "4.0", gemfile: "rails81" }
```

### gemfile の新規作成 / 削除

追加 Rails 用の gemfile は、既存の gemfile をテンプレに `~> X.Y.0` だけ変える。

```ruby
source "https://rubygems.org"

gem 'rails', '~> 8.1.0'
gem 'sqlite3'

gemspec path: '../'
```

不要になった Rails の gemfile は削除する。

### gemspec の下限更新

最小サポート版に合わせて 2 箇所を更新する。

```ruby
spec.required_ruby_version = '>= 3.3.0'      # サポート中の最小 Ruby
spec.add_dependency "rails", ">= 7.2.0"      # サポート中の最小 Rails
```

## 注意点

- **`source` は `https://rubygems.org`** を使う（`http://` は修正する）。
- **`ruby/setup-ruby@v1` の新メジャー対応**: Ruby 4.0 など出たばかりのメジャーは、
  setup-ruby がサポート済みか念のため確認する（通常はすぐ対応されている）。
- **`required_ruby_version` の引き上げは breaking change**。古い Ruby ユーザーが
  インストールできなくなるため、リリース時に gem バージョンの minor / major
  インクリメントが必要。これはこの作業とは別 PR / 別コミットで扱うのが無難。

## 落とし穴

- **gemspec の下限を上げ忘れる**と、CI から消したはずの古い Ruby/Rails が依然として
  `gem install` できてしまい、サポート表明と実態が食い違う。
- **gemfile とマトリクスの片方だけ**更新すると CI が壊れる（存在しない gemfile を
  参照する／使われない gemfile が残る）。必ず対で更新する。
- バージョンを除外する作業と、`source` の `https` 化のような無関係な修正を 1 コミットに
  混ぜない。論理単位ごとにコミットを分ける。
