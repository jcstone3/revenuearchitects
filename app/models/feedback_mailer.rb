class FeedbackMailer < ActionMailer::Base
  
  def feedback(feedback)
    recipients  = 'admin@revenuegrader.com'
    subject     = "[Feedback for YourSite] #{feedback.subject}"
    from 		= "#{feedback.email}"
    @feedback = feedback
    mail(:to => recipients, :subject => subject, :from => from)
  end
end
