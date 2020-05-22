# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

if Rails.env.development?
  user_is_not_exists = !User.where('length(stripe_account_id) > 0').exists?
  if user_is_not_exists
    message = <<~'EOT'


      @@@@@@@@ 販売者アカウントを用意してください @@@@@@@@

            $ rails db:create db:migrate connect_account:create

      @@@@@@@@ 販売者アカウントを用意してください @@@@@@@@

    EOT
    raise Exception, message
  end
end

run Rails.application
