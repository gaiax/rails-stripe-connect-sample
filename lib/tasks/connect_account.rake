# frozen_string_literal: true

namespace :connect_account do
  desc 'Connect Account（販売者アカウント）を作成する'
  task create: :environment do
    user = User.create(
      email: 'taro@example.com',
      password: 'password'
    )
    # https://stripe.com/docs/connect/required-verification-information#JP-individual-card_payments
    stripe_account = Stripe::Account.create(
      {
        # APIではCustomアカウントのみ作成可能（2020年05月22日現在）
        type: 'custom',
        country: 'JP',
        requested_capabilities: %w[card_payments transfers],
        business_type: 'individual',
        business_profile: {
          url: 'https://gaiax.co.jp/'
        },
        individual: {
          gender: 'male',
          first_name_kana: 'ハンバイ',
          first_name_kanji: '販売',
          last_name_kana: 'タロウ',
          last_name_kanji: '太郎',
          dob: {
            year: 2000,
            month: 4,
            day: 1
          },
          address_kana: {
            country: 'JP',
            postal_code: '1500001',
            state: 'ﾄｳｷﾖｳﾄ',
            city: 'ｼﾌﾞﾔ',
            town: 'ｼﾞﾝｸﾞｳﾏｴ 1-',
            line1: '5-8',
            line2: 'ｼﾞﾝｸﾞｳﾏｴﾀﾜｰﾋﾞﾙﾃﾞｨﾝｸﾞ22F'
          },
          address_kanji: {
            postal_code: '１５００００１',
            state: '東京都',
            city: '渋谷区',
            town: '神宮前　１丁目',
            line1: '５－８',
            line2: '神宮前タワービルディング22F'
          }
        },
        # 規約に同意する https://stripe.com/docs/connect/updating-accounts
        tos_acceptance: {
          date: Time.now.to_i,
          ip: '127.0.0.1'
        },
        # アプリケーションの独自データをmetadataで保持できる
        # 検索例: https://dashboard.stripe.com/test/search?query=metadata%3Auser_id%3D1
        metadata: {
          user_id: user.id
        }
      }
    )

    # 銀行口座を作成する
    # https://stripe.com/docs/connect/testing
    Stripe::Account.create_external_account(
      stripe_account.id,
      external_account: {
        object: 'bank_account',
        country: 'JP',
        currency: 'jpy',
        default_for_currency: true,
        account_number: '0001234',
        routing_number: '1100000',
        account_holder_name: 'ハンバイタロウ'
      }
    )

    user.stripe_account_id = stripe_account.id
    user.save

    Store.create(
      user_id: user.id,
      name: 'たろう商店',
      service_fee: 1000
    )

    Rails.logger.info "Created Stripe Connect account! #{user.stripe_account_id}"
  end
end
