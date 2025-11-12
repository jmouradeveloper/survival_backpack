Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication routes
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout
  
  # Registration routes
  get "signup", to: "registrations#new", as: :signup
  post "signup", to: "registrations#create"
  
  # API Token management
  resources :api_tokens, only: [:index, :create, :destroy]

  # Rotas Web - Gerenciamento de Alimentos
  resources :food_items
  
  # Rotas Web - Lotes de Suprimentos (FIFO)
  resources :supply_batches do
    member do
      post :consume
    end
    collection do
      get :fifo_order
    end
  end
  
  # Rotas Web - Rotações de Suprimentos
  resources :supply_rotations, only: [:index, :show, :new, :create, :destroy] do
    collection do
      post :consume_fifo
      get :statistics
    end
  end

  # Rotas Web - Notificações
  resources :notifications, only: [:index, :show, :destroy] do
    member do
      post :mark_as_read
    end
    collection do
      post :mark_all_as_read
      get :unread_count
    end
  end

  # Rotas Web - Preferências de Notificação
  resource :notification_preferences, only: [:show, :edit, :update] do
    post :subscribe_push
    delete :unsubscribe_push
    post :test_notification
  end

  # Rotas Web - Backups
  resources :backups, only: [:index, :new, :create] do
    collection do
      get :export
    end
  end

  # API Routes
  namespace :api do
    namespace :v1 do
      # API Authentication
      post "login", to: "sessions#create"
      delete "logout", to: "sessions#destroy"
      resources :api_tokens, only: [:index, :create, :destroy]
      
      resources :food_items do
        collection do
          get :statistics
        end
      end
      
      # API - Lotes de Suprimentos (FIFO)
      resources :supply_batches do
        member do
          post :consume
        end
        collection do
          get :fifo_order
          get :statistics
        end
      end
      
      # API - Rotações de Suprimentos
      resources :supply_rotations, only: [:index, :show, :create, :destroy] do
        collection do
          post :consume_fifo
          get :statistics
        end
      end

      resources :notifications, only: [:index, :show, :destroy] do
        member do
          post :mark_as_read
        end
        collection do
          post :mark_all_as_read
          get :unread_count
        end
      end

      resource :notification_preferences, only: [:show, :update] do
        post :subscribe_push
        delete :unsubscribe_push
      end

      # API - Backups
      get 'backups/export', to: 'backups#export'
      post 'backups/import', to: 'backups#import'
    end
  end

  # Defines the root path route ("/")
  root "food_items#index"
end
