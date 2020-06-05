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
      :city,
      :town,
      :line1,
      :line2,
      :agree_legal
    )
  end
end
