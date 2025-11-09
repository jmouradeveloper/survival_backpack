Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

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

  # API Routes
  namespace :api do
    namespace :v1 do
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
    end
  end

  # Defines the root path route ("/")
  root "food_items#index"
end
