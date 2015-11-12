class Usermailer < ActionMailer::Base
  default from: '"Revenue Grader" <noreply@revenuegrader.com>'
  def welcome(user)
    @user = user
    @url  = "http://www.revenuegrader.com/login"
    mail(:to => @user.email, :subject => "Welcome to Revenue Grader")
  end

  def reset_password_instructions(user)
    @resource = user
    mail(:to => @resource.email, :subject => "Reset password instructions", :tag => 'password-reset') do |format|
      format.html { render "usermailer/reset_password_instructions" }
    end
  end

  def new_signup_details(user)
    @user = user unless user.blank?
    mail(:to => "contact@revenuearchitects.com", :subject => "New SignUp", :tag => 'new-signup-details') do |format|
      format.html { render "usermailer/new_signup_details" }
    end
  end

  def complete_survey_details(user,company,survey)
    @survey = survey unless survey.blank?
    @company = company unless company.blank?
    @user = user unless user.blank?
    mail(:to => @user.email, :subject => "New Completed Survey Details", :tag => 'new-completed-survey') do |format|
      format.html { render "usermailer/complete_survey_details" }
    end
  end

  def contact_email(first_name, last_name, email,company_name,website,phone_number,your_message)
    @first_name = first_name
    @last_name = last_name
    @email = email
    @company_name = company_name
    @website = website
    @phone_number = phone_number
    @your_message = your_message

    mail(:to => "support.revenuegrader@icicletech.com, contact@revenuearchitects.com", :subject => "RevenueGrader: Contact Request", :tag => 'contact-request') do |format|
      format.html { render "usermailer/contactus" }
    end
  end
end
