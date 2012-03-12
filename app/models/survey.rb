class Survey < ActiveRecord::Base
	belongs_to :company
	has_many :responses
end
