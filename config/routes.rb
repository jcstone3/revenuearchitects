RevenueGrader::Application.routes.draw do
  #setting up user registeration
  devise_for :users, :path => "accounts", :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => "users/registrations", :sessions => "users/sessions" } do
      get 'sign_in', :to => 'users/sessions#new', :as => :new_user_session
      get 'sign_out', :to => 'users/sessions#destroy', :as => :destroy_user_session
      get 'accounts/sign_up', :to => 'users/registrations#new', :as => :new_user_registration
      get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
  end 
   
  resources :companies
  resources :authorizations
  resources :survey
  resources :industries
  resources :responses

  get 'survey/:id/question/:question_id' => 'survey#question', :as => 'questions'
  get 'survey/:id/report/' => 'survey#report', :as => 'reports'
  post 'survey/:id/question/:question_id' => 'survey#create_response', :as=> 'reponses'
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
    root :to => 'dashboard#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
