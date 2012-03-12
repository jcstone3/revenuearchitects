class Company < ActiveRecord::Base
	belongs_to :user
	belongs_to :industry
	has_many :surveys
end
