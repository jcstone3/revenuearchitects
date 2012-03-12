class SubSection < ActiveRecord::Base
	belongs_to :sub_section
	has_many :questions
end
