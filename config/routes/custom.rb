# frozen_string_literal: true

# Custom routes for Vertente customizations
# This file is kept separate to minimize merge conflicts with upstream Chatwoot routes.rb
# It is loaded via `draw :custom` in the main routes.rb file.

# WhatsApp Template Administration
resources :whatsapp_templates, only: [:index] do
  collection do
    post :sync
    post :update_visibilities
  end
end

# Kanban Board
resources :inboxes, only: [] do
  resources :kanban_stages, only: [:index, :create, :update, :destroy] do
    collection do
      post :reorder
    end
  end
  resource :kanban, only: [:show], controller: 'kanban' do
    patch :move
  end
end
