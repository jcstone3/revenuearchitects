class Question < ActiveRecord::Base

  acts_as_ordered :order => 'id'
  #permanent_records(for soft delete)
  #default_scope where(:deleted_at => nil)

  #Relationships
  belongs_to :sub_section
  has_one :response
  
  

  #Validations
	validates :name, :presence =>{:message=>"Question can't be blank"}
	validates :description, :presence =>{:message=>"Description can't be blank"}
	validates :sub_section_id, :presence =>{:message=>"Section can't be blank"}
  validates :points, :presence =>{:message=>"Question points can't be blank"}
#Scopes
 # default_scope :order => :sequence  

  # Configurations
	self.per_page = 10

  scope :find_section_questions, lambda{|section_id| {
    :select=>"questions.id",
    :joins=>"left outer join sub_sections on questions.sub_section_id = sub_sections.id 
             inner join sections on sections.id = sub_sections.section_id",
    :conditions=>"sections.id =#{section_id}",
    :order => "questions.id ASC"
}}


scope :find_question_count, lambda{|section_id| {
    :select=>"count(*) as question_count",
    :joins=>"right outer join sub_sections on questions.sub_section_id = sub_sections.id 
             inner join sections on sections.id = sub_sections.section_id",
    :conditions=>"sections.id =#{section_id} "
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

