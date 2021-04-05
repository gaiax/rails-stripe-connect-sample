# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  root 'root#index'
  post '/create_session', controller: :root, action: :create_session
  get '/success', controller: :root, action: :success
  get '/cancel', controller: :root, action: :cancel

  resources :accounts, only: %i[] do
    collection do
      get '/', action: :edit
      post '/', action: :edit
    end
  end
  resources :account_links, only: [] do
    collection do
      get '/', action: :start
      get 'success', action: :success
      get 'failure', action: :failures
    end
  end
end
