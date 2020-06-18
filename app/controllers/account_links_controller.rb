# frozen_string_literal: true

class AccountLinksController < ApplicationController
  def start
    redirect_to root_path if current_user.blank?
    if current_user.stripe_account_id.blank?
      stripe_account = Stripe::Account.create(
        {
          # APIではCustomアカウントのみ作成可能（2020年05月22日現在）
          type: 'custom',
          country: 'JP',
          email: current_user.email,
          requested_capabilities: %w[card_payments transfers],
          metadata: {
            user_id: current_user.id
          }
        }
      )
      current_user.stripe_account_id = stripe_account.id
      current_user.save
    end

    base_url = "#{request.scheme}://#{request.host}:#{request.port}"
    # >Account Link URLs are short-lived and can be used only once because they grant access to the account holder’s personal information.
    # ref: https://stripe.com/docs/connect/connect-onboarding
    #
    # URLの有効時間は非常に短いので注意すること
    # 例えば、rails consoleで次のコードを実行してURLをブラウザにコピペすると `not be found` となる。
    account_links = Stripe::AccountLink.create(
      {
        account: current_user.stripe_account_id,
        failure_url: "#{base_url}#{failure_account_links_path}",
        success_url: "#{base_url}#{success_account_links_path}",
        type: 'custom_account_verification',
        collect: 'currently_due'
      }
    )
    redirect_to account_links.url
  end

  def success
    stripe_account = Stripe::Account.retrieve(current_user.stripe_account_id)
    # true: Account Linksでアカウント情報の入力が完了している
    if stripe_account.details_submitted != current_user.details_submitted
      current_user.details_submitted = stripe_account.details_submitted
      current_user.save
    end
    redirect_to accounts_path
  end

  def failure
    # TODO:
    redirect_to root_path
  end
end
