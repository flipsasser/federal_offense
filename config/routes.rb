# frozen_string_literal: true

FederalOffense::Engine.routes.draw do
  if FederalOffense::Engine.server
    mount FederalOffense::Engine.server => FederalOffense::Engine.cable_config.mount_path
  end

  resources :messages, only: %i[index show update], path: "" do
    member do
      post :destroy, as: :destroy, path: "destroy"
    end

    collection do
      post :destroy_all
    end
  end
end
