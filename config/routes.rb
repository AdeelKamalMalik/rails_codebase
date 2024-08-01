# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :blogs
  draw :turbo

  # Jumpstart views
  if Rails.env.local?
    mount Jumpstart::Engine, at: "/jumpstart"
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # Administrate
  authenticated :user, lambda { |u| u.admin? } do
    namespace :admin do
      if defined?(Sidekiq)
        require "sidekiq/web"
        require "sidekiq/cron/web"
        mount Sidekiq::Web => "/sidekiq"
      end
      mount Flipper::UI.app(Flipper) => "/flipper" if defined?(::Flipper::UI)

      resources :announcements
      resources :users do
        resource :impersonate, module: :user
      end
      resources :connected_accounts
      resources :accounts
      resources :account_users
      resources :plans
      namespace :pay do
        resources :customers
        resources :charges
        resources :payment_methods
        resources :subscriptions
      end

      root to: "dashboard#show"
    end
  end

  # API routes
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resource :auth
      resource :me, controller: :me
      resource :password
      resources :accounts
      resources :users
      resources :notification_tokens, only: :create
    end
  end

  # User account
  devise_for :users,
    controllers: {
      omniauth_callbacks: ("users/omniauth_callbacks" if defined? OmniAuth),
      registrations: "users/registrations",
      sessions: "users/sessions"
    }.compact
  devise_scope :user do
    get "verify_email", to: "users/sessions#verify_email"
    get "session/otp", to: "users/sessions#otp", format: :json
  end

  resources :announcements, only: [:index, :show]
  resources :api_tokens
  resources :accounts do
    member do
      patch :switch
    end

    resource :transfer, module: :accounts
    resources :account_users, path: :members
    resources :account_invitations, path: :invitations, module: :accounts do
      member do
        post :resend
      end
    end
  end
  resources :account_invitations

  # Payments
  namespace :subscriptions do
    resource :stripe, controller: :stripe, only: [:show]
    resource :paddle_billing, controller: :paddle_billing, only: [:show, :edit]
    resource :paddle_classic, controller: :paddle_classic, only: [:show]
  end
  resources :subscriptions do
    collection do
      patch :billing_settings
    end
    resource :payment_method, module: :subscriptions
    resource :cancel, module: :subscriptions
    resource :pause, module: :subscriptions
    resource :resume, module: :subscriptions
    resource :upcoming, module: :subscriptions
  end
  resources :charges do
    member do
      get :invoice
    end
  end

  resources :alerts, only: [:update, :create]
  resources :agreements, module: :users
  namespace :account do
    resource :password
    resource :settings
  end
  resources :notifications, only: [:index, :show]
  namespace :users do
    resources :mentions, only: [:index]
  end
  namespace :user, module: :users do
    resource :two_factor, controller: :two_factor do
      get :backup_codes
      get :verify
      get :setup
      get :setup_method
      get :update_setup
      get :update_m_setup
      get :add_phone
      get :verify_phone
      patch :send_verification_code
      post :check_verification_code
    end

    resource :onboarding, controller: :onboarding do
      get :privacy
      get :profile_information
      get :how_it_works
      get :do_it_later
    end
    resources :connected_accounts
  end

  namespace :action_text do
    resources :embeds, only: [:create], constraints: {id: /[^\/]+/} do
      collection do
        get :patterns
      end
    end
  end

  scope controller: :static do
    get :about
    get :terms
    get :privacy
    get :pricing
  end

  post :sudo, to: "users/sudo#create"
  resources :contracts, param: :public_id do
    collection do
      get :sample
      get :download_csv
      get :vendors
    end
    member do
      post :upload_file
      get :archive
      get :unarchive
    end
  end
  resources :contract_files, only: [:index, :update, :destroy], param: :id do
    patch "move", on: :member
    patch "update_document_type", on: :member
  end
  resources :products
  resources :blobs, only: [:destroy], param: :signed_id
  match "/404", via: :all, to: "errors#not_found"
  match "/500", via: :all, to: "errors#internal_server_error"
  resources :vendors, param: :public_id do
    member do
      get :archive
      get :download_csv
      get :unarchive
    end
  end

  authenticated :user do
    root to: "dashboard#show", as: :user_root
    # Alternate route to use if logged in users should still see public root
    # get "/dashboard", to: "dashboard#show", as: :user_root
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  # Public marketing homepage
  root to: redirect("/users/sign_in")
  get :sort, to: "dashboard#sort"
end
