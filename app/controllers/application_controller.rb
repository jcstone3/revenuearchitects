#application controller
class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_in_path_for(resource)
    if resource.is_a? User
      companies_path
    else #resource is an admin
      admin_root_path
    end
  end 
end
