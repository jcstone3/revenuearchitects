class Section < ActiveRecord::Base
	belongs_to :questionnire
	has_many :sub_sections
end
