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
  attr_accessor :bank_number
  attr_accessor :bank_branch_number
  attr_accessor :bank_account_number
  attr_accessor :bank_account_holder_name
  validates :store_name, presence: true
  validates :service_fee, numericality: { greater_than: 0 }
  validates :bank_number, format: { with: /\A[0-9０-９]{4}\z/, message: '銀行コードを数字3桁で入力して下さい' }
  validates :bank_branch_number, format: { with: /\A[0-9０-９]{3}\z/, message: '支店コードを数字4桁で入力して下さい' }
  validates :bank_account_number, format: { with: /\A[0-9０-９]{7}\z/, message: '口座番号を数字7桁で入力して下さい' }
  validates :bank_account_holder_name, format: { with: /\A[\p{katakana}\p{blank}ー－）\)]+\z/, message: '入力例： カ）タロウ' }

  def bank_routing_number
    "#{@bank_number}#{@bank_branch_number}"
  end

end
