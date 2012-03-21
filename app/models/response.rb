class Response < ActiveRecord::Base
	#validates :name, :presence => true
	validates :answer_1, :presence => true
    validates :survey_id, :presence => true
    validates :question_id, :presence => true

	belongs_to :question
	belongs_to :survey
end
# == Schema Information
#
# Table name: responses
#
#  id          :integer         not null, primary key
#  survey_id   :integer
#  question_id :integer
#  answer_1    :string(255)
#  answer_2    :string(255)
#  answer_3    :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

