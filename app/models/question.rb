class Question < ActiveRecord::Base
	belongs_to :sub_section
	has_many :responses
end
