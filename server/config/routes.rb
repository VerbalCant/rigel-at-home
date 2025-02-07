Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

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
  end
end
