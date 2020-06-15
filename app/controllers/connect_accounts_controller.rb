# frozen_string_literal: true

class ConnectAccountsController < ApplicationController
  def new
    @individual_form = IndividualForm.new
  end

  def create
    @individual_form = IndividualForm.new(create_params)
    return render :new unless @individual_form.validate

    # https://stripe.com/docs/connect/required-verification-information#JP-individual-card_payments
    stripe_account = Stripe::Account.create(
      {
        # APIではCustomアカウントのみ作成可能（2020年05月22日現在）
        type: 'custom',
        country: 'JP',
        requested_capabilities: %w[card_payments transfers],
        business_type: 'individual',
        business_profile: {
          url: @individual_form.business_url
        },
        individual: {
          gender: @individual_form.gender,
          first_name_kana: @individual_form.first_name_kana,
          first_name_kanji: @individual_form.first_name_kanji,
          last_name_kana: @individual_form.last_name_kana,
          last_name_kanji: @individual_form.last_name_kanji,
          dob: {
            year: @individual_form.dob_year,
            month: @individual_form.dob_month,
            day: @individual_form.dob_day
          },
          address_kanji: {
            postal_code: @individual_form.postal_code,
            state: @individual_form.state,
            city: @individual_form.city,
            town: @individual_form.town,
            line1: @individual_form.line1,
            line2: @individual_form.line2
          },
          address_kana: {
            postal_code: @individual_form.postal_code,
            state: @individual_form.state_kana,
            city: @individual_form.city_kana,
            town: @individual_form.town_kana,
            line1: @individual_form.line1_kana,
            line2: @individual_form.line2_kana
          }
        },
        # 規約に同意する https://stripe.com/docs/connect/updating-accounts
        tos_acceptance: {
          date: Time.now.to_i,
          ip: request.remote_ip
        },
        # アプリケーションの独自データをmetadataで保持できる
        # 検索例: https://dashboard.stripe.com/test/search?query=metadata%3Auser_id%3D1
        metadata: {
          user_id: current_user.id
        }
      }
    )

    # 銀行口座を作成する
    # 登録済みの銀行口座を更新することはできない。後に銀行口座を更新する場合、作成時と同様に `create_external_account` を叩く。
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
    if e.message.start_with?('Invalid address')
      @individual_form.errors.add(:postal_code, :invalid_address)
    elsif e.message.start_with?('The routing number')
      @individual_form.errors.add(:invalid_bank_account, :invalid_bank_account)
    end
    render :new
  end

  def create_params
    params.require(:individual_form).permit(
      :store_name,
      :service_fee,
      :business_url,
      :email,
      :gender,
      :first_name_kana,
      :first_name_kanji,
      :last_name_kana,
      :last_name_kanji,
      :dob_year,
      :dob_month,
      :dob_day,
      :postal_code,
      :state,
      :state_kana,
      :city,
      :city_kana,
      :town,
      :town_kana,
      :line1,
      :line1_kana,
      :line2,
      :line2_kana,
      :bank_number,
      :bank_branch_number,
      :bank_account_number,
      :bank_account_holder_name,
      :agree_legal
    )
  end
end
