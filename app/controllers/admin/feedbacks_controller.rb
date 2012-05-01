class Admin::FeedbacksController < ApplicationController
layout "admin"
	def feed_index
		@feedbacks = Feedback.find(:all)
	end
end
