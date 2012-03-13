class Section < ActiveRecord::Base
	belongs_to :questionnaire
	has_many :sub_sections
end
# == Schema Information
#
# Table name: sections
#
#  id         :integer         not null, primary key
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

