class Section < ActiveRecord::Base
  #Relationships
	belongs_to :questionnaire
	has_many :sub_sections, :dependent => :destroy

  #Scopes
  #default_scope :order => :sequence

  #Validations
  validates :name, :presence => {:message=> "Name can't be blank"}
  validates :questionnaire_id, :presence => true  

  def self.last_secuence
    (Section.last.nil? )? 1 :  Section.last.sequence.to_i + 1 
  end
	
end
# == Schema Information
#
# Table name: sections
#
#  id               :integer         not null, primary key
#  name             :string(50)
#  sequence         :integer
#  question_count   :integer
#  total_points     :integer
#  questionnaire_id :integer
#  is_active        :boolean
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

