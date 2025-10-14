# frozen_string_literal: true

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Dashboard
  root "dashboard#index"

  # Settings
  resource :settings, only: [:edit, :update] do
    post :test_radarr_connection
    post :test_sonarr_connection
  end

  # Movies
  resources :movies, only: [:index, :show] do
    collection { post :sync_all }
    member do
      post :refresh
      post :ignore
      post :unignore
    end
  end

  # Shows and Seasons
  resources :shows, only: [:index, :show] do
    collection { post :sync_all }
    member do
      post :refresh
      post :ignore
      post :unignore
    end
    resources :seasons, only: [:show]
  end
end
