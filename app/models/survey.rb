class Survey < ActiveRecord::Base
	validates :size, :presence => true #,:numericality => {:greater_than => 0}
	validates :revenue, :presence => true #, :numericality => {:greater_than => 0}
	#validates :start_date, :presence => true
	#validates :end_date, :presence => true
    validates :company_id, :presence => true	
    
	belongs_to :company
	has_many :responses


    def self.check_numericality(params)
    	params = params
    	if params.to_i.is_a?(Integer) && params.to_i > 0
    	 return true
    	else
    	 return false
    	end 	
    end
   
    def self.find_question(params)
    	@question = Question.find_by_id(params)
    	if @question.present?
         return true
    	else
    	 return false
        end
    end	

  #total response for a section
def self.calculate_response_for_section(survey_id, section_id)
    questions = []  
    @section = Section.find(section_id)
    @section.sub_sections.each do |s|
     s.questions.each do |q|
       questions << q.id
     end
    end
  @survey = self.find(survey_id)
    @sur_responses = @survey.responses.find_all_by_question_id(questions)   
    calculate_response(@sur_responses)
end   

#total response for a subsection
def self.calculate_response_for_subsection(survey_id, sub_section_id)
  questions = []  
  @sub_section = SubSection.find(sub_section_id)
  @sub_section.questions.each do |q|
       questions << q.id
  end
  @survey = self.find(survey_id)
  @sur_responses = @survey.responses.find_all_by_question_id(questions) 
  calculate_response(@sur_responses)
end 

#calculate response 
def self.calculate_response(survey_response)  
  @total_score = 0 
  survey_response.each do |response|
    @score = 0
    @score = get_individual_response_score(response.id, response.question_id)    
    @total_score += @score 
  end
    return @total_score
 end

 def self.get_question_ids(section)
  section_questions =[]
  section = Section.find(section)
  section.sub_sections.each do |subsect|
  subsect.questions.each do |q|
       section_questions << q.id
   end 
 end
   return section_questions
end

def self.get_response_score_for(survey_id)
  @total = 0
 @survey = self.find(survey_id) 
 @survey.responses.each do |response|
   @total += get_individual_response_score(response.id, response.question_id)
 end
 return @total
end 

def get_avg_calculated_score(response_survey_id, response_questions_id, section_id)
 @avg_response_score = 0
 survey = self.find(response_survey_id)
 company = Company.find(survey.company_id)
 
 company_all = Company.find(:all, conditions=>"industry_id=#{company.industry.id} 
                                              and id !=#{company.id} ")
 if company_all
    response = Response.find(:all, :select =>"responses.question_id, responses.answer_1",
               :joins=>"left outer join questions where questions.id = responses.question_id 
                        left outer join sub_sections on sub_sections.id = questions.sub_section_id
                        inner join sections on sections.id = sub_sections.section_id
                        where sections_id=1")
    response.each do |res|
      @score =  get_individual_response_score(response_id, response_question_id)
      total_score += @score 
    end  
    @avg_response_score = (total_score/response.count)
  end  
    return @avg_response_score
end    

#individual score for each response
def self.get_individual_response_score(response_id, response_question_id)
  score = 0
  question = Question.find(response_question_id)
  response = Response.find(response_id)
  case question.points
        when 5 
          if response.answer_1 == 1
            score = -1            
          end
           if response.answer_1 == 2
            score = 0
          end 
           if response.answer_1 == 3
            score = 1
          end
           if response.answer_1 == 4
            score = 3
          end
           if response.answer_1 == 5
            score = 5
          end         

       when 10 
          if response.answer_1 == 1
            score = -2
          end
           if response.answer_1 == 2
            score = 0
          end 
           if response.answer_1 == 3
            score = 2
          end
           if response.answer_1 == 4
            score = 6
          end
           if response.answer_1 == 5
            score = 10
          end          

        when 20 
          if response.answer_1 == 1
            score = -4
          end
           if response.answer_1 == 2
            score = 0
          end 
           if response.answer_1 == 3
            score = 4
          end
           if response.answer_1 == 4
            score = 12
          end
           if response.answer_1 == 5
            score = 20
          end
        end        
       return score
end


end
# == Schema Information
#
# Table name: surveys
#
#  id         :integer         not null, primary key
#  company_id :integer
#  size       :integer
#  revenue    :integer
#  start_date :date
#  end_date   :date
#  is_active  :boolean
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

