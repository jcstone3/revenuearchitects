class FeedbackMailer < ActionMailer::Base
  default from: "admin@revenuegrader.com"
  def feedback(feedback)
    recipients  = 'admin@revenuegrader.com'
    subject     = "[Feedback for YourSite] #{feedback.subject}"
    from 		= "#{feedback.email}"
    @feedback = feedback
    mail(:to => recipients, :subject => subject, :from => from)
  end
end
