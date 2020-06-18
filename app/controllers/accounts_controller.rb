# frozen_string_literal: true

class AccountsController < ApplicationController
  def edit
    if request.method_symbol == :get
      @individual_form = IndividualForm.new
      return
    end
    @individual_form = IndividualForm.new(edit_params)
    return render :edit unless @individual_form.validate

    # https://stripe.com/docs/connect/required-verification-information#JP-individual-card_payments
    stripe_account = Stripe::Account.update(
      current_user.stripe_account_id,
      {
        business_profile: {
          url: @individual_form.business_url
        }
      }
    )

    # 銀行口座を作成する。
    # 登録済みの銀行口座を更新することはできない。銀行口座を更新する場合、作成時と同様に `create_external_account` を叩く。
    external_account = Stripe::Account.create_external_account(
      stripe_account.id,
      external_account: {
        object: 'bank_account',
        country: 'JP',
        currency: 'jpy',
        default_for_currency: true,
        account_number: @individual_form.bank_account_number,
        routing_number: @individual_form.bank_routing_number,
        account_holder_name: @individual_form.bank_account_holder_name
      }
    )

    current_user.stripe_account_id = stripe_account.id
    current_user.external_account_id = external_account.id
    current_user.save

    store = Store.create(
      user_id: current_user.id,
      name: @individual_form.store_name,
      service_fee: @individual_form.service_fee
    )
    if stripe_account.id.present? && store.persisted?
      redirect_to root_path
    else
      render :new
    end
  rescue Stripe::InvalidRequestError => e
    logger.error e
    if e.message.start_with?('The routing number')
      @individual_form.errors.add(:invalid_bank_account, :invalid_bank_account)
    end
    render :new
  end

  def edit_params
    params.require(:individual_form).permit(
      :store_name,
      :service_fee,
      :business_url,
      :bank_number,
      :bank_branch_number,
      :bank_account_number,
      :bank_account_holder_name
    )
  end
end
