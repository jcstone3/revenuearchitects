class Question < ActiveRecord::Base
	belongs_to :sub_section
	has_one :response
end
