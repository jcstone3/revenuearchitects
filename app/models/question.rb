class Question < ActiveRecord::Base
	belongs_to :sub_section
	has_one :response
end
# == Schema Information
#
# Table name: questions
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  sequence       :integer
#  is_active      :boolean
#  sub_section_id :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

