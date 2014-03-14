class SiteController < ApplicationController
  layout "layout_website", except: :index
  layout "website", only: :index

  def index
    if user_signed_in?
     redirect_to new_survey_url
    elsif admin_signed_in?
     redirect_to  admin_root_url
    else
    end
  end

  def aboutus

  end

  def contactus

  end

  def privacy_policy

  end

  def show
  end
end
