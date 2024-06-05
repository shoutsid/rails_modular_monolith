# frozen_string_literal: true

Rails.application.routes.draw do
  draw(:ollama)

  authenticated do
    root to: 'application#home'
  end
end
