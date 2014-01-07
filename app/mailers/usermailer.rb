class Usermailer < ActionMailer::Base
  default from: "noreply@revenuegrader.com"
  def welcome(user)
    @user = user
    @url  = "http://www.revenuegrader.com/login"
    mail(:to => user.email, :subject => "Welcome to Revenue Grader")
  end

  def reset_password_instructions(user)
    @resource = user
    mail(:to => @resource.email, :subject => "Reset password instructions", :tag => 'password-reset') do |format|
      format.html { render "usermailer/reset_password_instructions" }
    end
  end

  def new_signup_details(user)
    @user = user
    mail(:to => "contact@revenuearchitects.com, admin@revenuegrader.com", :subject => "New Signup Details", :tag => 'new-signup-details') do |format|
      format.html { render "usermailer/new_signup_details" }
    end
  end

end
