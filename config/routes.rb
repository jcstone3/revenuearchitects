RevenueGrader::Application.routes.draw do 

  #admin settings
  namespace :admin do 
   get '/dashboard' => "dashboard#show", :as => :dashboard 
   get '/users' => "users#index", :as => "users" 
   get '/users/activate_user/:id' => "users#activate_user", :as => "users_active"  
   get '/users/deactivate_user/:id' => "users#deactivate_user", :as => "users_deactive" 
   get '/users/update_user/:company_id' => "users#update_user", :as => "users_update_user"
   get '/questions' => "questions#index", :as=>"questions"
   get '/questions/new' => "questions#new", :as=>"new_questions"
   post '/questions/create' => "questions#create", :as=>"create_question"
   get '/sections' => "section#index", :as => "sections"
   get '/section/new' => "section#new", :as => "new_section" 
   get '/subsection/new' => "section#subsection_new", :as => "new_subsection"
   post '/section/create' => "section#create", :as => "create_section"
   post '/subsection/create' => "section#create_subsection", :as => "create_subsection"
   get  '/section/edit/:id' => "section#edit_section", :as => "edit_section"
   get  '/subsection/edit/:id' => "section#edit_subsection", :as => "edit_subsection"
   post '/section/update' => "section#update", :as => "update_section"
   post '/subsection/update' => "section#update_subsection", :as => "update_subsection"
   get '/settings' => "settings#index", :as => "settings"   
   get '/reports' => "section#reports_index", :as => "reports"
   root :to =>  "dashboard#index"
   resources :users

  end
  devise_for :admins, :controllers => { :sessions => "admin/sessions", :registrations => "admin/registrations"} do 
   get 'admins/login' => 'admin/sessions#new', :as => "new_admin_session"
   get 'admins/logout' => 'admin/sessions#destroy', :as => "destroy_admin_session"
   get 'admins/signup' => 'admin/registrations#new', :as => "new_admin_registration" 
  end  
  
  #setting up user registration
  devise_for :users, :path => "", :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => "users/registrations", :sessions => "users/sessions", :passwords => "users/passwords"} do
      get '/login' =>'users/sessions#new', :as => :new_user_session
      get '/logout' => 'users/sessions#destroy', :as => :destroy_user_session
      get '/signup' => 'users/registrations#new', :as => :new_user_registration
      get '/forgot_password/:resource' => 'users/passwords#new', :as => :new_password
      get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru' #third party authentication
  end 
   
  resources :companies
  resources :authorizations
  resources :survey
  resources :industries
  resources :responses

  get 'survey/:id/question/:question_id' => 'survey#question', :as => 'questions' 
  get 'survey/:id/previous_question/:question_id' => 'survey#previous_question', :as => 'previous_question' 
  get 'survey/:id/report/' => 'survey#report', :as => 'reports'
  post 'survey/:id/question/:question_id' => 'survey#create_response', :as=> 'reponses'
  post 'survey/:id/update_question/:question_id' => 'survey#update_response', :as=> 'reponses_update'
  get 'survey/:id/download' => 'survey#download_result', :as=>'download'
  get 'survey/:id/reports' => 'survey#reports', :as=>'reports_show'
  get 'survey/show' =>'survey#show', :as=>'continue_survey'
  get 'survey/get_response_status/:id' => 'survey#get_response_status', :as=>'get_response_status'
  get 'survey/:id/report/detailed_view' => 'survey#report_detailed', :as=>'detailed_report'
  get 'survey/:id/confirm_survey' => 'survey#confirm_survey', :as=>'confirm_survey'
  get 'survey/:id/close_survey' => 'survey#close_survey', :as=>'close_survey'


  #site controller maps about us, contact us privacy policy
  match "about-us" =>'site#aboutus', :as => 'aboutus'
  match "contactus" =>'site#conactus', :as => 'contactus'
  match "privacy_policy" =>'site#privacy_policy', :as => 'privacy_policy'
  match "show" =>'site#show', :as => 'show'


  
  #defalut error page
   match "*path" => 'dashboard#error_handle404', :as => 'error_handle404'
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
    root :to => 'site#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
