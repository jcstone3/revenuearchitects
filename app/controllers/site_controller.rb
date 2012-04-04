class SiteController < ApplicationController
	layout "application"
  def index
    if user_signed_in?
     redirect_to new_survey_url  
    elsif admin_signed_in?
     redirect_to  admin_root_url 
    else
    end  
  end

  def aboutUs
  end

  def contactUs
  end

  def privacy_policy
  end

  def show
  end
end
