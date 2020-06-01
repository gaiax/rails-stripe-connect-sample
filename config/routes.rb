# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  root 'root#index'
  post '/create_session', controller: :root, action: :create_session
  get '/success', controller: :root, action: :success
  get '/cancel', controller: :root, action: :cancel
end
