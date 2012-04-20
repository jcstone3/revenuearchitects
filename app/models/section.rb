class Section < ActiveRecord::Base
	validates :name, :presence => {:message=> "Name can't be blank"}
	validates :questionnaire_id, :presence => true	

	belongs_to :questionnaire
	has_many :sub_sections


	
end
# == Schema Information
#
# Table name: sections
#
#  id               :integer         not null, primary key
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  questionnaire_id :integer
#  name             :string(255)
#  question_count   :integer
#  total_points     :integer
#

