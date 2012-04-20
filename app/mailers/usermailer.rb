class Usermailer < ActionMailer::Base
  default from: "from@example.com"
  def welcome(user)
    @user = user
    @url  = "http://www.revenue-grader.com/login"
    mail(:to => user.email, :subject => "Welcome to Revenue Grader")
  end
end
