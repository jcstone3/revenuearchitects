class Question < ActiveRecord::Base
  #Relationships
  belongs_to :sub_section
  has_one :response


  #Validations
	validates :name, :on=>:update, :presence =>{:message=>"Question can't be blank"}
	validates :description, :on=>:update,:presence =>{:message=>"Description can't be blank"}
	validates :sub_section_id, :on=>:update, :presence =>{:message=>"Section can't be blank"}

#Scopes
 # default_scope :order => :sequence  

  # Configurations
	self.per_page = 10


scope :find_question_count, lambda{|section_id| {
    :select=>"count(*) as question_count",
    :joins=>"right outer join sub_sections on questions.sub_section_id = sub_sections.id 
             inner join sections on sections.id = sub_sections.section_id",
    :conditions=>"sections.id =#{section_id}"
}}
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
#  points         :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  description    :string(255)
#

