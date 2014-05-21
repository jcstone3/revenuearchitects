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
    if !params[:first_name].blank? && !params[:last_name].blank? && !params[:email].blank? && !params[:company_name].blank?
      first_name = params[:first_name]
      last_name = params[:last_name]
      email = params[:email]
      company_name = params[:company_name]
      website = params[:website]
      phone_number = params[:phone_number]
      your_message = params[:your_message]
      Usermailer.contact_email(first_name, last_name, email,company_name,website,phone_number,your_message).deliver
      redirect_to contactus_path, notice: 'Email sent'
    else
      # raise MyApp::MissingFieldError
      redirect_to contactus_path, notice: 'Please enter all required fields.'
    end
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
