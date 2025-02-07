Rails.application.routes.draw do
  # Devise/OmniAuth routes with custom path
  devise_for :users,
             path: 'api/auth',
             controllers: {
               omniauth_callbacks: 'api/omniauth_callbacks'
             },
             defaults: { format: :json }

  # API routes that don't need Devise/OmniAuth
  namespace :api do
    # Agent management
    post 'agents/register', to: 'agents#register'
    post 'agents/heartbeat', to: 'agents#heartbeat'
    put 'agents/status', to: 'agents#update_status'
    put 'agents/capabilities', to: 'agents#update_capabilities'

    # Task management
    resources :tasks, only: [:index] do
      collection do
        post 'request', to: 'tasks#request_task'
      end
      member do
        put 'progress', to: 'tasks#update_progress'
        put 'complete', to: 'tasks#complete'
        put 'fail', to: 'tasks#fail'
      end
    end

    # Task definitions
    resources :task_definitions, only: [:index, :show, :create, :update, :destroy]
    
    # Authentication test routes
    get 'auth/login_options', to: 'auth_test#login_options'
    get 'auth/test', to: 'auth_test#test_auth'
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.

  # Defines the root path route ("/")
  # root "posts#index"
end
