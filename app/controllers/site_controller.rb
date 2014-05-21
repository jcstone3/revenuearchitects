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

  def send_mail
    first_name = params[:first_name]
    last_name = [:last_name]
    email = params[:email]
    company_name = params[:company_name]
    website = [:website]
    phone_number = [:phone_number]
    your_message = [:your_message]
    Usermailer.contact_email(first_name, last_name, email,company_name,website,phone_number,your_message).deliver
    redirect_to contactus_path, notice: 'Email sent'
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
