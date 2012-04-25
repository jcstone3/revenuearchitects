class Feedback < ActiveRecord::Base
  attr_accessor :subject, :email, :comment, :page
  validates_presence_of :comment
  # def initialize(params = {})
  #   self.subject = params[:subject]
  #   self.email = params[:email]
  #   self.comment = params[:comment]
  #   self.page = params[:page]
  # end

  # def valid?
  #   self.comment && !self.comment.strip.blank?
  # end
end
