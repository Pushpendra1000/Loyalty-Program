# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq/cron/web'
# Sidekiq::Web.use ActionDispatch::Cookies
# Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: "_interslice_session"

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  mount Sidekiq::Web => '/sidekiq'

  resources :users do
    post :login, on: :collection
  end

  resources :transactions, only: %i[index create show]
  resources :rewards, only: %i[index show update]
end
