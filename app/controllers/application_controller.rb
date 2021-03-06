#application controller
class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :layout_by_resource

  before_filter :authenticate_user

  #before_filter :check_resource_type
  #to set the redirect path after sign in/ registration
  def after_sign_in_path_for(resource)
    if resource.is_a? User
       flash[:success] = "Welcome! #{resource.username} You have signed up successfully."
       if current_user.companies.first
          new_survey_path  #user already has company, then redirect to survey page
       else
          new_company_path  #redirect to create a new company
       end
    else #resource is an admin
      flash[:success] = "Welcome! #{resource.name} You have signed up successfully."
      admin_root_path
    end
  end



#to authenticate the user for login
 #def authenticate_user!
 # if current_user.nil?
 #   redirect_to new_user_session_url, :alert => "You must first log in to access this page"
 # end
#end

def authenticate_admin!
  if admin_signed_in?
     admin_root_path
   else
    redirect_to new_admin_session_path :alert => "You must first log in to access this page"
  end
end

# unless config.consider_all_requests_local
#     rescue_from Exception, with: :render_500
#      rescue_from ActionController::RoutingError, with: :render_404
#      rescue_from ActionController::UnknownController, with: :render_404
#      rescue_from ActionController::UnknownAction, with: :render_404
#      rescue_from ActiveRecord::RecordNotFound, with: :render_404
#   end


# unless Rails.application.config.consider_all_requests_local
#   rescue_from Exception, :with => :render_error
# end

# def render_error(exception)
#   ExceptionNotifier::Notifier.exception_notification(request.env, exception).deliver
# end



# def error_handle404
#     if current_user.nil?
#      redirect_to new_user_session_url, :alert => "You must first log in to access this page"
#     else
#        redirect_path_for_user
#     end
# end

 def redirect_path_for_user
   if current_user.companies.first
     redirect_to new_survey_path and return #user already has company, then redirect to survey page
   end
 end


protected

def authenticate_user
     if Rails.env.staging?
        authenticate_or_request_with_http_basic do |username, password|
          username == "survey" && password == "survey$33"
        end
    end
end

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

#error handling
  #   def render_404(exception)
  #   @not_found_path = exception.message
  #   respond_to do |format|
  #     format.html { render file: 'public/404.html', status: 404 }
  #     format.all { render nothing: true, status: 404 }
  #   end
  # end

  # def render_500(exception)
  #   @error = exception
  #   respond_to do |format|
  #     format.html { render file: 'public/500.html', status: 500 }
  #     format.all { render nothing: true, status: 500}
  #   end
  # end

#def check_resource_type
#  if devise_controller? && resource_name == :user
#      if current_user.companies.first
#          new_survey_url  #user already has company, then redirect to survey page
#       else
#          new_company_url   #redirect to create a new company
#       end
#    elsif devise_controller? && resource_name == :admin  #resource is an admin
#      admin_root_url
#    else
#       new_user_session_url
#    end
#end
end
