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
    (last.nil? )? 1 :  last.sequence.to_i + 1 
  end

  def self.total_points
     order(:sequence).sum(&:total_points)
  end

  def self.section_questions(survey_id)
    Section.find(:all,
       :select => "count(responses.question_id) as question_attempted",
       :joins => "left outer join sub_sections on sections.id = sub_sections.section_id 
                  left outer join questions on questions.sub_section_id = sub_sections.id 
                  left outer join responses on (responses.question_id = questions.id and 
                  responses.survey_id=#{survey_id})",
       :group => "sections.id", :order => "sections.id")
  end

  def self.section_questions_total
    Section.find(:all,
      :select => "count(questions.position) as question_total, sections.id",
      :joins => "left outer join sub_sections on sections.id = sub_sections.section_id 
      left outer join questions on questions.sub_section_id = sub_sections.id",
      :group => "sections.id", :order => "id ASC")
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

