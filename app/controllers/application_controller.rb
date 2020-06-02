class ApplicationController < ActionController::Base
    before_action :bind_header_variables

    def bind_header_variables
      @my_store = Store.find_by(user_id: current_user.id)
    end
end
