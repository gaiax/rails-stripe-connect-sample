# frozen_string_literal: true

class RootController < ApplicationController
  def index; end

  # JavaScriptから叩くアクション
  # ref: app/javascript/packs/root.js
  def create_session
    price = 1000
    # Connect Accountが存在しなければサーバーが起動しないようになっている
    stripe_account_id = User.first.stripe_account_id
    # Direct Chargeを始める
    # https://stripe.com/docs/payments/checkout/connect#direct-charges
    checkout_session = Stripe::Checkout::Session.create(
      {
        payment_method_types: ['card'],
        line_items: [{
          name: 'サービス料',
          # 国ごとに最低決済金額が決まっている
          # https://stripe.com/docs/currencies#minimum-and-maximum-charge-amounts
          amount: price,
          currency: 'jpy',
          quantity: 1
        }],
        payment_intent_data: {
          application_fee_amount: (price * 0.1).to_i
        },
        success_url: "#{request.protocol}#{request.host_with_port}#{success_path}",
        cancel_url: "#{request.protocol}#{request.host_with_port}#{cancel_path}"
      }, { stripe_account: stripe_account_id }
    )

    render json: {
      session_id: checkout_session.id,
      stripe_account_id: stripe_account_id
    }, status: :created
  end

  def success; end

  def cancel; end
end
