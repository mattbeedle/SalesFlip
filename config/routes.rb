Salesflip::Application.routes.draw do
  devise_for :users

  root :to => 'pages#index'

  match '/instant', :to => InstantSearchController.action(:search)

  match 'profile', :to => 'users#profile'

  match 'help(/:action)(/:locale)', :to => "help", :as => "help"

  match "external_updates/user", to: "external_updates#update_user", as: "user_external_updates"

  resources :users, :comments, :tasks, :deleted_items,
    :searches, :invitations, :emails, :campaigns

  resources :infomail_templates

  resources :opportunities do
    get :create_offer_request, :on => :member
    get :rework_offer_request, :on => :member
  end

  resources :leads do
    resources :infomails, :only => [:new, :create]

    member do
      get :finish
      get :convert
      put :promote
      put :reject
      put :duplicate
    end

    collection do
      get :export
      get :next
    end
  end
  resources :lead_imports

  resources :contacts do
    get :export, :on => :collection
  end

  resources :accounts do
    get :export, :on => :collection
  end

  namespace :administration do
    root :to => 'pages#index'
    resources :leads do
      collection do
        put :assignee
        put :campaign
        put :rating
        put :source
        put :status, :to => "leads#update_status"
      end
    end

    resources :users, :only => [] do
      put :masquerade, :on => :member
      put :unmasquerade, :on => :collection
    end

    resources :opportunity_stages do
      get :confirm_delete, :on => :member
    end
  end
end
