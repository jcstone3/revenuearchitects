class SiteController < ApplicationController
  layout :resolve_layout

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

  private

  def resolve_layout
    case action_name
    when "index"
      "website"
    else
      "layout_website"
    end
  end
end
