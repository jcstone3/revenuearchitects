#application controller
class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_in_path_for(resource)
    if resource.is_a? User
      #user already has company, then redirect to survey page	
      if current_user.companies.first
     	new_survey_url
     #redirect to create a new company	
      else      	
        new_company_url
      end
    else #resource is an admin
      admin_root_path
    end
  end 

  	
end
