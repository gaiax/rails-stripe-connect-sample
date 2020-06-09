# frozen_string_literal: true

class IndividualForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  def self.kana_pattern
    '\A[\p{katakana}\p{blank}ー－]+\z'
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
  attr_accessor :city
  attr_accessor :town
  attr_accessor :line1
  attr_accessor :line2
  attr_accessor :agree_legal
  validates :store_name, presence: true
  validates :service_fee, numericality: { greater_than: 0 }
  validates :email, format: { with: /\A\w[\w\.]+\w+@\w+\.\w+\z/i, message: 'メールアドレスを入力してください' }
  validates :gender, presence: true
  validates :first_name_kana, format: { with: /#{kana_pattern}/, message: 'カタカナを入力して下さい' }
  validates :first_name_kanji, presence: true
  validates :last_name_kana, format: { with: /#{kana_pattern}/, message: 'カタカナを入力して下さい' }
  validates :last_name_kanji, presence: true
  validates :validate_dob, presence: false
  validates :postal_code, presence: true
  validates :state, presence: true
  validates :city, presence: true
  validates :town, presence: true
  validates :line1, presence: true
  validates :agree_legal, acceptance: { message: '規約の同意は必須です' }

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
