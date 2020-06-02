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
  attr_accessor :dob_year
  attr_accessor :dob_month
  attr_accessor :dob_day
  attr_accessor :postal_code
  attr_accessor :state
  attr_accessor :city
  attr_accessor :town
  attr_accessor :line1
  attr_accessor :line2
  attr_accessor :agree_legal
  validates :store_name, presence: true
  validates :service_fee, presence: true, numericality: { greater_than: 0 }
  validates :email, presence: true
  validates :gender, presence: true
  validates :first_name_kana, presence: true, format: { with: /#{kana_pattern}/, message: 'カタカナで入力して下さい。' }
  validates :first_name_kanji, presence: true
  validates :last_name_kana, presence: true, format: { with: /#{kana_pattern}/, message: 'カタカナで入力して下さい。' }
  validates :last_name_kanji, presence: true
  validates :dob_year, presence: true, numericality: { greater_than_or_equal_to: 1900 }
  validates :dob_month, presence: true # , inclusion: 1..12, numericality: { only_integer: false }
  validates :dob_day, presence: true # , inclusion: 1..31, numericality: { only_integer: false }
  validates :postal_code, presence: true
  validates :state, presence: true
  validates :city, presence: true
  validates :town, presence: true
  validates :line1, presence: true
  validates :agree_legal, :acceptance => {:message => '規約の同意は必須です'}
end
