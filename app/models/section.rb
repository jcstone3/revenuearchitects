class Section < ActiveRecord::Base
	belongs_to :questionnaire
	has_many :sub_sections
end
