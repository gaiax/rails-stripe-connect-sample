# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :bind_header_variables

  def bind_header_variables
    if current_user.present? && current_user.id.present?
      @my_store = Store.find_by(user_id: current_user.id)
    end
  end
end
