class Question < ActiveRecord::Base

  #permanent_records(for soft delete)
  default_scope where(:deleted_at => nil)

  acts_as_list
  #acts_as_ordered :order => 'position'
  
  
  #Relationships
  belongs_to :sub_section
  has_one :response
  
  #attr_accessible :name, :description, :position, :sequence, :is_active, :sub_section_id, :points

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

def self.fix_order_to_check
  Question.order(:sequence,"to_check desc").each_with_index{|q,i| q.update_attributes(sequence: (i+1)) }
end

def self.last_secuence
  (last.nil? )? 1 :  last.sequence.to_i + 1 
end

def self.id_by_sequence(sequence_id)
  (find_by_sequence(sequence_id))? find_by_sequence(sequence_id).id : nil  
end

def self.next_secuence(question_id)
  (next_in_sequence(question_id).empty? )? 0 : next_in_sequence(question_id).first.sequence
end

def self.next_in_sequence(question_id)
  where("sequence > ?", question_id).order(:sequence)
end

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

