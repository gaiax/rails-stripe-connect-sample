# rails-stripe-connect-sample

Stripe ConnectのCustomアカウントを利用してDirect Chargeで決済するサンプル。

## セットアップ

1. [Stripeダッシュボード](https://dashboard.stripe.com/test/dashboard)でアカウントを作成する
2. Stripeダッシュボードで[連結されたアカウント](https://dashboard.stripe.com/test/connect/accounts/overview)の利用を開始する
3. `.env.example` をコピーして `.env` を作成する
4. `.env` を開き、[StripeのAPIキー](https://dashboard.stripe.com/test/apikeys)をセットする
5. 次のコマンドを実行する

```sh
### macOSの場合
$ bundle config --local build.mysql2 "--with-ldflags=-L/usr/local/opt/openssl/lib"


### MySQLを起動する
$ docker-compose up -d db

$ yarn install
$ bundle install --path=vendor
$ bundle exec rails db:create db:migrate

### StripeのConnect Account（販売者アカウント）を作成する
$ bundle exec rails connect_account:create
```

## サーバーを起動する

```sh
$ gem install foreman
$ foreman start
```

## リソース

- [Stripe Connect: アカウントタイプ](https://stripe.com/jp/connect/account-types)
- [Using Connect with Custom accounts | Stripe Connect](https://stripe.com/docs/connect/custom-accounts)
- [Creating charges and taking fees | Stripe Connect](https://stripe.com/docs/connect/charges)
