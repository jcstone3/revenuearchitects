class DashboardController < ApplicationController

def index
end

def error_handle404
    if current_user.nil?
     redirect_to new_user_session_url, :alert => "You must first log in to access this page"
    else
       redirect_path_for_user 
    end
end	
end
