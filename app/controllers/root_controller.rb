# frozen_string_literal: true

class RootController < ApplicationController
  def index
    @stores = Store.all.order('updated_at DESC')
    # pp Stripe::Account.update(
    #   current_user.stripe_account_id,
    #   {
    #     business_profile: {
    #       url: 'https://gaiax.co.jp/'
    #     }
    #   }
    # )
    # stripe_account = Stripe::Account.retrieve(current_user.stripe_account_id)
    # pp stripe_account
  end

  # JavaScriptから叩くアクション
  # ref: app/javascript/packs/root.js
  def create_session
    store = Store.find(create_session_params[:store_id])
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
          amount: store.service_fee,
          currency: 'jpy',
          quantity: 1
        }],
        payment_intent_data: {
          application_fee_amount: (store.service_fee * 0.1).to_i
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

  private

  def create_session_params
    params.permit(:store_id)
  end
end
