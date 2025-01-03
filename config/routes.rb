# frozen_string_literal: true

Rails.application.routes.draw do
  resources :companies, only: :create do
    post :import, on: :collection
  end
end
