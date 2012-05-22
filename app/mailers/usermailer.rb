class Usermailer < ActionMailer::Base
  default from: "noreply@revenuegrader.com"
  def welcome(user)
    @user = user
    @url  = "http://www.revenuegrader.com/login"
    mail(:to => user.email, :subject => "Welcome to Revenue Grader")
  end
end
