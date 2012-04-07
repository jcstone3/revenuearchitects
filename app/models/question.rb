class Question < ActiveRecord::Base
	validates :name, :presence =>{:message=>"Question can't be blank"}
	validates :sub_section_id, :presence => true

	belongs_to :sub_section
	has_one :response

	self.per_page = 10
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

