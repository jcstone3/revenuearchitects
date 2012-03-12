class Questionnaire < ActiveRecord::Base
	belongs_to :industry
	has_many :sections
end
