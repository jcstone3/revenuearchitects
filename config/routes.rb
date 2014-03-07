RevenueGrader::Application.routes.draw do

  resources :feedback, :only => [:new, :create]

  #admin settingss
  namespace :admin do
   get '/dashboard' => "dashboard#show", :as => :dashboard
   get '/users' => "users#index", :as => "users"
   get '/users/activate_user/:id' => "users#activate_user", :as => "users_active"
   get '/users/deactivate_user/:id' => "users#deactivate_user", :as => "users_deactive"
   get '/users/update_user/:company_id' => "users#update_user", :as => "users_update_user"
   get '/users/:id/survey-report/:survey_id' => "users#survey_report", :as => "users_survey_report"
   get '/questions' => "questions#index", :as=>"questions"
   get '/questions/new' => "questions#new", :as=>"new_questions"
   get '/questions/edit/:id' => "questions#edit", :as=>"edit_questions"
   get '/questions/delete/:id' => "questions#destroy", :as=>"delete_questions"
   post 'questions/update/:id' => "questions#update", :as=>"update_questions"
   post '/questions/create' => "questions#create", :as=>"create_question"
   get '/sections' => "section#index", :as => "sections"
   get '/section/new' => "section#new", :as => "new_section"
   get '/subsection/details/:id' => "section#details_subsection", :as => "details_subsection"
   get '/subsection/new' => "section#subsection_new", :as => "new_subsection"
   post '/section/create' => "section#create", :as => "create_section"
   post '/subsection/create' => "section#create_subsection", :as => "create_subsection"
   get  '/subsection/edit/:id' => "section#edit_subsection", :as => "edit_subsection"
   get '/subsection/delete/:id' => "section#destroy_subsection", :as => "delete_subsection"
   post '/subsection/update/:id' => "section#update_subsection", :as => "update_subsection"
   get '/settings' => "settings#index", :as => "settings"
   get '/reports' => "section#reports_index", :as => "reports"
   get '/feedbacks' => "feedbacks#feed_index", :as =>"feedbacks"
   root :to =>  "dashboard#index"
   resources :users

  end
   #setting up user registration
  devise_for :users, :path => "",:path_names => { :sign_in => 'login', :sign_out => 'logout', :sign_up => 'register' } , :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :registrations => "users/registrations", :sessions => "users/sessions", :passwords => "users/passwords"} do
      get '/login' =>'users/sessions#new', :as => :new_user_session
      get '/logout' => 'users/sessions#destroy', :as => :destroy_user_session
      get '/register' => 'users/registrations#new', :as => :new_user_registration
      get '/forgot-password/:resource' => 'users/passwords#new', :as => :new_password
      get '/edit-password/:resource' => 'users/passwords#edit', :as => :edit_password
      put '/update-password/:resource' => 'users/passwords#update', :as => :update_password
      get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru' #third party authentication
  end
  devise_for :admins, :controllers => { :sessions => "admin/sessions", :registrations => "admin/registrations"} do
   get 'admins/login' => 'admin/sessions#new', :as => "new_admin_session"
   get 'admins/logout' => 'admin/sessions#destroy', :as => "destroy_admin_session"
   get 'admins/sign-up' => 'admin/sessions#new', :as => "new_admin_session"
  end



  resources :companies
  resources :authorizations
  resources :surveys do
    get :sub_section, on: :collection
  end
  resources :industries
  resources :responses

  get 'surveys/:id/question/:question_id' => 'surveys#question', :as => 'questions'
  get 'surveys/:id/report/' => 'surveys#report', :as => 'reports'
  post 'surveys/:id/question/:question_id' => 'surveys#create_response', :as=> 'reponses'
  put 'surveys/:id/question/:question_id' => 'surveys#create_response', :as=> 'reponses'
  post 'surveys/:id/update-question/:question_id' => 'surveys#update_response', :as=> 'reponses_update'
  get 'surveys/:id/download' => 'surveys#download_result', :as=>'download'
  get 'surveys/:id/reports' => 'surveys#reports', :as=>'reports_show'
  get 'surveys/show' =>'surveys#show', :as=>'continue_survey'
  get 'surveys/get-response-status/:id' => 'surveys#get_response_status', :as=>'get_response_status'
  get 'surveys/:id/report/detailed-view' => 'surveys#report_detailed', :as=>'detailed_report'
  get 'surveys/:id/confirm-survey' => 'surveys#confirm_survey', :as=>'confirm_survey'
  get 'surveys/:id/close-survey' => 'surveys#close_survey', :as=>'close_survey'
  get 'surveys/:id/compare' => 'surveys#compare', :as=>'compare'
  get 'surveys/:id/compare-strategy' => 'surveys#compare_strategy', :as=>'compare_strategy'
  get 'surveys/:id/compare-system' => 'surveys#compare_system', :as=>'compare_system'
  get 'surveys/:id/compare-programs' => 'surveys#compare_programs', :as=>'compare_programs'
  post 'feedback/create' => 'feedback#create', :as=>'create_feedback'

  #site controller maps about us, contact us privacy policy
  match "about-us" =>'site#aboutus', :as => 'aboutus'
  match "contact-us" =>'site#contactus', :as => 'contactus'
  match "privacy" =>'site#privacy_policy', :as => 'privacy_policy'
  match "show" =>'site#index', :as => 'show'

  # import excel
  get 'surveys/:id/import_excel' => 'surveys#import_excel', :as=>'import_excel'

  # import CSV
  get 'surveys/:id/import_csv' => 'surveys#import_csv', :as=>'import_csv'

  #create survey object
  post 'surveys/create_survey' => 'surveys#create_survey', :as=>'create_survey'

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
