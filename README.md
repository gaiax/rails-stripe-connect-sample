# rails-stripe-connect-sample

## セットアップ

1. [Stripeダッシュボード](https://dashboard.stripe.com/test/dashboard)でアカウントを作成する
2. Stripeダッシュボードで[連結されたアカウント](https://dashboard.stripe.com/test/connect/accounts/overview)の利用を開始する
3. `.env.example` をコピーして `.env` を作成する
4. `.env` を開き、[StripeのAPIキー](https://dashboard.stripe.com/test/apikeys)をセットする
5. 次のコマンドを実行する

```sh
### MySQLを起動する
$ docker-compose -d db

$ yarn install
$ bundle install --path=vendor
$ rails db:create db:migrate

### StripeのConnect Account（販売者アカウント）を作成する
$ rails connect_account:create
```

## サーバーを起動する

```sh
$ gem install foreman
$ foreman start
```
