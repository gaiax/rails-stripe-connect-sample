# frozen_string_literal: true

class IndividualForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  def self.number_pattern
    '\A[0-9０-９]+\z'
  end

  def self.kana_pattern
    '\A[\p{katakana}\p{blank}ー－\-0-9０-９]+\z'
  end

  attr_accessor :store_name
  attr_accessor :business_url
  attr_accessor :service_fee
  attr_accessor :email
  attr_accessor :gender
  attr_accessor :first_name_kana
  attr_accessor :first_name_kanji
  attr_accessor :last_name_kana
  attr_accessor :last_name_kanji
  attr_accessor :dob_year, :dob_month, :dob_day
  attr_accessor :postal_code
  attr_accessor :state
  attr_accessor :state_kana
  attr_accessor :city
  attr_accessor :city_kana
  attr_accessor :town
  attr_accessor :town_kana
  attr_accessor :line1
  attr_accessor :line1_kana
  attr_accessor :line2
  attr_accessor :line2_kana
  attr_accessor :agree_legal
  attr_accessor :bank_number
  attr_accessor :bank_branch_number
  attr_accessor :bank_account_number
  attr_accessor :bank_account_holder_name
  validates :store_name, presence: true
  validates :service_fee, numericality: { greater_than: 0 }
  validates :email, format: { with: /\A\w[\w\.\-\_\+]+\w+@\w+\.\w+\z/i, message: 'メールアドレスを入力してください' }
  validates :gender, presence: true
  validates :first_name_kana, format: { with: /#{kana_pattern}/, message: 'カタカナで入力して下さい' }
  validates :first_name_kanji, presence: true
  validates :last_name_kana, format: { with: /#{kana_pattern}/, message: 'カタカナで入力して下さい' }
  validates :last_name_kanji, presence: true
  validates :validate_dob, presence: false
  validates :postal_code, presence: true
  validates :state, presence: true
  validates :state_kana, presence: true, format: { with: /#{kana_pattern}/, message: 'カタカナで入力して下さい' }
  validates :city, presence: true
  validates :city_kana, presence: true, format: { with: /#{kana_pattern}/, message: 'カタカナで入力して下さい' }
  validates :town, presence: true
  validates :town_kana, presence: true, format: { with: /#{kana_pattern}/, message: 'カタカナで入力して下さい' }
  validates :line1, presence: true
  validates :line1_kana, presence: true, format: { with: /#{kana_pattern}/, message: 'カタカナで入力して下さい' }
  validates :agree_legal, acceptance: { message: '規約の同意は必須です' }
  validates :bank_number, format: { with: /\A[0-9０-９]{3}\z/, message: '銀行コードを数字3桁で入力して下さい' }
  validates :bank_branch_number, format: { with: /\A[0-9０-９]{4}\z/, message: '支店コードを数字4桁で入力して下さい' }
  validates :bank_account_number, format: { with: /\A[0-9０-９]{7}\z/, message: '口座番号を数字7桁で入力して下さい' }
  validates :bank_account_holder_name, format: { with: /\A[\p{katakana}\p{blank}ー－）\)]+\z/, message: '入力例： カ）タロウ' }

  def bank_routing_number
    "#{@bank_number}#{@bank_branch_number}"
  end

  def dob
    is_numeric = @dob_year.is_a?(Numeric) && @dob_month.is_a?(Numeric) && @dob_day.is_a?(Numeric)
    if is_numeric && Date.valid_date?(@dob_yea, @dob_month, @dob_day)
      Date.new(@dob_year, @dob_month, @dob_day)
    end
  end

  def dob_year=(value)
    value.tr!('０-９', '0-9') if value.is_a?(String)
    @dob_year = value.to_i if value.to_i > 0
  end

  def dob_month=(value)
    value.tr!('０-９', '0-9') if value.is_a?(String)
    @dob_month = value.to_i if value.to_i > 0
  end

  def dob_day=(value)
    value.tr!('０-９', '0-9') if value.is_a?(String)
    @dob_day = value.to_i if value.to_i > 0
  end

  private

  def validate_dob
    is_numeric = dob_year.is_a?(Numeric) && dob_month.is_a?(Numeric) && dob_day.is_a?(Numeric)
    unless is_numeric
      errors.add(:dob_year, :invalid_dob)
      return
    end
    valid = dob_year > 1900 &&
            Date.valid_date?(dob_year, dob_month, dob_day) &&
            Date.new(dob_year, dob_month, dob_day).past?
    errors.add(:dob_year, :invalid_dob) unless valid
  end
end
