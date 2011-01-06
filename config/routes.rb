Salesflip::Application.routes.draw do
  devise_for :users

  root :to => 'pages#index'

  match 'profile', :to => 'users#profile'

  resources :users, :comments, :tasks, :deleted_items,
    :searches, :invitations, :emails, :opportunities

  resources :leads do
    member do
      get :convert
      put :promote
      put :reject
    end
    get   :export, :on => :collection
    post  :import, :on => :collection
    get   :choose_import, :on => :collection
  end

  resources :contacts do
    get :export, :on => :collection
  end

  resources :accounts do
    get :export, :on => :collection
  end

  namespace :administration do
    root :to => 'pages#index'

    resources :opportunity_stages do
      get :confirm_delete, :on => :member
    end
  end
end
