class FeedbackController < ApplicationController
  layout false

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(params[:feedback])
    logger.info "#{@feedback}"
    if @feedback.valid?
      logger.info "in feedback valid"
      
      if @feedback.save
        logger.info "in feedback save"
      FeedbackMailer.feedback(@feedback).deliver
      render :status => :created, :text => '<h3>Thank you for your feedback!</h3>'
    else
      render :action => 'new', :status => 500
      @error_message = "Please enter your #{@feedback.subject.to_s.downcase}"

	  # Returns the whole form back. This is not the most effective
      # use of AJAX as we could return the error message in JSON, but
      # it makes easier the customization of the form with error messages
      # without worrying about the javascript.
      
    end
    else
       render :action => 'new', :status => 500
    end  
  end
end
