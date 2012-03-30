#application controller
class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :layout_by_resource
  #to set the redirect path after sign in/ registration
  def after_sign_in_path_for(resource)
    if resource.is_a? User
       flash[:success] = "Welcome! You have signed up successfully." 
       if current_user.companies.first         
          new_survey_url  #user already has company, then redirect to survey page               
       else
          new_company_url   #redirect to create a new company            
       end     
    else #resource is an admin
      admin_root_url
    end
  end 

#to authenticate the user for login
 #def authenticate_user!
 # if current_user.nil?
 #   redirect_to new_user_session_url, :alert => "You must first log in to access this page"
 # end
#end

def error_handle404
    if current_user.nil?
     redirect_to new_user_session_url, :alert => "You must first log in to access this page"
    else
       redirect_path_for_user 
    end
end

 def redirect_path_for_user
   if current_user.companies.first          
     redirect_to new_survey_path  #user already has company, then redirect to survey page              
   end
 end 

protected
def handle_unverified_request
  true
end

def layout_by_resource
  if devise_controller? && resource_name == :admin
    "admin"
  else
    "application"
  end
end
end
