class Response < ActiveRecord::Base
	#validates :name, :presence => true
	validates :answer_1, :presence => true
    validates :survey_id, :presence => true
    validates :question_id, :presence => true

	belongs_to :question
	belongs_to :survey

	scope :get_response, lambda{ |section_id, surveyid| { 
				:select => "questions.id as questions_id,responses.id as response_id, sections.id as section_id, questions.name,responses.answer_1 as score, responses.answer_2 as in_plan, responses.answer_3, questions.points, sections.name as section_name, sub_sections.name as sub_sect_name, avg(responses.answer_1) as avg_score, responses.survey_id as survey_id ", 
				:joins => "right outer join questions on (responses.question_id = questions.id and responses.survey_id =#{surveyid})
				             left outer join sub_sections on questions.sub_section_id = sub_sections.id 
				             left outer join sections on sections.id = sub_sections.section_id",   
				:conditions =>  "sections.id=#{section_id}",
				:group => "questions.id, responses.id, sections.id, responses.survey_id, questions.name, responses.answer_1, responses.answer_2, responses.answer_3, sections.name, sub_sections.name, questions.points",            
				:order=>"questions.id"

}}

  scope :get_resultresponse, lambda{ |section_id, surveyid| {
			  :select =>"responses.answer_1, questions.id as question_id",
			  :joins=>"right outer join questions on (questions.id=responses.question_id and responses.survey_id=#{surveyid})
			           left outer join sub_sections on questions.sub_section_id = sub_sections.id 
			           inner join sections on sections.id = sub_sections.section_id",
			   :conditions =>  "sections.id = #{section_id}",
			   :order => "questions.id ASC"
}}

scope :get_response_for_priority, lambda{ |surveyid, action| { 
	  :select => "questions.id as questions_id,responses.id as response_id, sections.id as section_id, questions.name,responses.answer_1 as score, responses.answer_2 as in_plan, responses.answer_3, questions.points, sections.name as section_name, sub_sections.name as sub_sect_name, avg(responses.answer_1) as avg_score, responses.survey_id as survey_id ", 
      :joins => "left outer join questions on responses.question_id = questions.id 
             left outer join sub_sections on questions.sub_section_id = sub_sections.id 
             left outer join sections on sections.id = sub_sections.section_id",   
      :conditions =>  "responses.survey_id =#{surveyid} and responses.answer_3 like'#{action}'",
      :group => "questions.id, responses.id, sections.id, responses.survey_id, questions.name, responses.answer_1, responses.answer_2, responses.answer_3, sections.name, sub_sections.name, questions.points",                                      
      :order=>"questions.id"

}}


scope :get_overall_response_on_companies, lambda{|company_ids, section_id, survey_id|{
     :select=>"responses.answer_1, questions.id, surveys.id",
     :joins =>"right outer join questions on (questions.id=responses.question_id and responses.survey_id!=#{survey_id})
              left outer join surveys on surveys.company_id in (#{company_ids}) 
              left outer join sub_sections on questions.sub_section_id = sub_sections.id 
              inner join sections on sections.id = sub_sections.section_id",
     :conditions =>  "sections.id = #{section_id}",
     :group=>"surveys.id,responses.answer_1, questions.id",
     :order=>"questions.id"        
     
}}

scope :get_overall_response_without_companies, lambda{|section_id, survey_id|{
     :select=>"count(*), responses.answer_1, questions.id",
     :joins =>"right outer join questions on (questions.id=responses.question_id and responses.survey_id!=#{survey_id})
              left outer join surveys on responses.survey_id = surveys.id 
              left outer join sub_sections on questions.sub_section_id = sub_sections.id 
              inner join sections on sections.id = sub_sections.section_id",
     :conditions =>  "sections.id = #{section_id}",
     :group=>"questions.id, responses.answer_1",
     :order=>"questions.id"        
 }}

 scope :get_response_for_all_sections, lambda{|survey_id|{
 	:select =>"responses.answer_1, questions.id",
    :joins=>"right outer join questions on (questions.id=responses.question_id and responses.survey_id=#{survey_id})
           left outer join sub_sections on questions.sub_section_id = sub_sections.id 
           inner join sections on sections.id = sub_sections.section_id",
    :order => "questions.id ASC"
 }}

 scope :find_response_for_all_sections_company, lambda{|company_ids,survey_id|{
    :select=>"responses.answer_1, questions.id, surveys.id",
    :joins =>"right outer join questions on (questions.id=responses.question_id and responses.survey_id=#{survey_id})
              left outer join surveys on surveys.company_id in (#{company_ids}) 
              left outer join sub_sections on questions.sub_section_id = sub_sections.id 
              inner join sections on sections.id = sub_sections.section_id",
    :group=>"surveys.id,responses.answer_1, questions.id",
    :order=>"questions.id"
 }}

scope :find_response_for_sections_without_company, lambda{|survey_id|{
 	:select=>"count(*), responses.answer_1, questions.id",
     :joins =>"right outer join questions on (questions.id=responses.question_id and responses.survey_id=#{survey_id})
              left outer join surveys on responses.survey_id = surveys.id 
              left outer join sub_sections on questions.sub_section_id = sub_sections.id 
              inner join sections on sections.id = sub_sections.section_id",
     :group=>"questions.id, responses.answer_1",
     :order=>"questions.id" 
}}

scope :find_average_response, lambda{|section_id|{
	  :select =>"responses.id, responses.question_id, responses.answer_1",
      :joins=>"left outer join questions on questions.id = responses.question_id 
               left outer join sub_sections on sub_sections.id = questions.sub_section_id
               inner join sections on sections.id = sub_sections.section_id",
       :conditions=>" sections.id=#{section_id}"
	}}
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

