class Questionnaire < ActiveRecord::Base
	validates :name, :presence => true
	validates :description, :presence => true
	#validates :industry_id, :presence => true

	#belongs_to :industry
	has_many :sections
end
# == Schema Information
#
# Table name: questionnaires
#
#  id          :integer         not null, primary key
#  name        :string(150)
#  description :string(500)
#  is_active   :boolean
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

