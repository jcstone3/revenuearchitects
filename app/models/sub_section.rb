class SubSection < ActiveRecord::Base
	validates :name, :presence => true
	validates :section_id, :presence => true

	belongs_to :section
	has_many :questions
end
# == Schema Information
#
# Table name: sub_sections
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :string(255)
#  order       :string(255)
#  is_active   :boolean
#  section_id  :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

