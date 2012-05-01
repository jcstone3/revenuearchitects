class Feedback < ActiveRecord::Base
  attr_accessor :subject, :email, :comment, :page
  validates_presence_of :email, :comment
  validates_format_of :email,:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,:message => "Please provide valid email id"
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
