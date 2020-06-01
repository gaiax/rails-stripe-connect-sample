# frozen_string_literal: true

class Store < ApplicationRecord
  validates :service_fee, numericality: { greater_than_or_equal_to: 0 }
end
