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
 
   def self.get_result(section_id, surveyid)
    @responses = Response.find(:all, 
  :select => "questions.id as questions_id,responses.id as response_id, sections.id as section_id, questions.name,responses.answer_1 as score, responses.answer_2 as in_plan, responses.answer_3, questions.points, sections.name as section_name, sub_sections.name as sub_sect_name, avg(responses.answer_1) as avg_score, responses.survey_id as survey_id ", 
  :joins => "right outer join questions on (responses.question_id = questions.id and responses.survey_id =#{surveyid})
             left outer join sub_sections on questions.sub_section_id = sub_sections.id 
             left outer join sections on sections.id = sub_sections.section_id   
             where sections.id=#{section_id}",
   :group => "questions.id, responses.id, sections.id, responses.survey_id, questions.name, responses.answer_1, responses.answer_2, responses.answer_3, sections.name, sub_sections.name, questions.points",            
   :order=>"questions.id") 
   return @responses
   end 

  def self.get_result_action(surveyid, action)
    @responses = Response.find(:all, 
  :select => "questions.id as questions_id,responses.id as response_id, sections.id as section_id, questions.name,responses.answer_1 as score, responses.answer_2 as in_plan, responses.answer_3, questions.points, sections.name as section_name, sub_sections.name as sub_sect_name, avg(responses.answer_1) as avg_score, responses.survey_id as survey_id ", 
  :joins => "left outer join questions on responses.question_id = questions.id 
             left outer join sub_sections on questions.sub_section_id = sub_sections.id 
             left outer join sections on sections.id = sub_sections.section_id   
             where responses.survey_id =#{surveyid} and responses.answer_3 like'#{action}'",
  :group => "questions.id, responses.id, sections.id, responses.survey_id, questions.name, responses.answer_1, responses.answer_2, responses.answer_3, sections.name, sub_sections.name, questions.points",                                      
   :order=>"questions.id") 
   return @responses
   end 

  def self.get_section_graph(section_id, survey_id)
  require 'rubygems'
 require 'google_chart'
 @section = Section.find(section_id)   
 @survey = Survey.find(survey_id)
 @question_count = Question.find(:all,
    :select=>"count(*) as question_count",
    :joins=>"right outer join sub_sections on questions.sub_section_id = sub_sections.id 
             inner join sections on sections.id = sub_sections.section_id where sections.id =#{section_id}")
 @response = Response.find(:all,
  :select =>"responses.answer_1, questions.id as question_id",
  :joins=>"right outer join questions on (questions.id=responses.question_id and responses.survey_id=#{@survey.id})
           left outer join sub_sections on questions.sub_section_id = sub_sections.id 
           inner join sections on sections.id = sub_sections.section_id
           where sections.id = #{section_id}",
   :order => "questions.id ASC")
  @response_all = []
  
  #Average response for all survey
  
  @company = Company.find(@survey.company_id)
  @industry  = Industry.find(@company.industry_id)
  @companies = Company.find(:all,
   :select => "industries.id, companies.id",
   :joins =>"right outer join industries on companies.industry_id = industries.id   
   where industries.id = #{@company.industry_id} and companies.id !=#{@survey.company_id}"
   )
  if @companies.present?
  @company_ids=@companies.collect(&:id).join(', ')
  @response_all = Response.find(:all,
     :select=>"responses.answer_1, questions.id, surveys.id",
     :joins =>"right outer join questions on (questions.id=responses.question_id and responses.survey_id!=#{@survey.id})
              left outer join surveys on surveys.company_id in (#{@company_ids}) 
              left outer join sub_sections on questions.sub_section_id = sub_sections.id 
              inner join sections on sections.id = sub_sections.section_id
              where sections.id = #{section_id}",
     :group=>"surveys.id,responses.answer_1, questions.id",
     :order=>"questions.id"        
     )
  else
    @response_all = Response.find(:all,
     :select=>"count(*), responses.answer_1, questions.id",
     :joins =>"right outer join questions on (questions.id=responses.question_id and responses.survey_id!=#{@survey.id})
              left outer join surveys on responses.survey_id = surveys.id 
              left outer join sub_sections on questions.sub_section_id = sub_sections.id 
              inner join sections on sections.id = sub_sections.section_id
              where  sections.id = #{section_id}",
     :group=>"questions.id, responses.answer_1",
     :order=>"questions.id"        
     )
  end 
  
  
  GoogleChart::LineChart.new("900x330", "#{@section.name}", false) do |line_gph|
    line_gph.data "Your Response", @response.map(&:answer_1).collect{|i| i.to_i}, '00ff00'
    line_gph.data "Overall Response", @response_all.map(&:answer_1).collect{|i| i.to_i}, 'ff0000'
    line_gph.axis :y, :range =>[0,5], :labels =>[0,1,2,3,4,5], :font_size =>10, :alignment =>:center
    line_gph.axis :x, :range =>[0,@question_count.first.question_count], :font_size =>10, :alignment =>:center
    line_gph.show_legend = true
    line_gph.shape_marker :circle, :color => '0000ff', :data_set_index => 0, :data_point_index => -1, :pixel_size => 5
    line_gph.grid :x_step => 100.0/10, :y_step=>100.0/10, :length_segment =>1, :length_blank => 0
    @line_graph_programs =  line_gph.to_url
  end
   return @line_graph_programs
  end  

def self.get_overall_graph(survey_id)
  require 'rubygems'
 require 'google_chart'
  @sections = Section.all  
  @allSection = Section.all 
  @survey = Survey.find(survey_id)
  @question_count =Question.all.count
  @response = Response.find(:all,
  :select =>"responses.answer_1, questions.id",
  :joins=>"right outer join questions on (questions.id=responses.question_id and responses.survey_id=#{@survey.id})
           left outer join sub_sections on questions.sub_section_id = sub_sections.id 
           inner join sections on sections.id = sub_sections.section_id
           ",
   :order => "questions.id ASC")
  @response_all = []
  @sections = Section.all
  #Average response for all survey 
  @company = Company.find(@survey.company_id)  
  @companies = Company.find(:all,
   :select => "industries.id, companies.id",
   :joins =>"right outer join industries on companies.industry_id = industries.id   
   where industries.id = #{@company.industry_id} and companies.id !=#{@survey.company_id}"
   )
   if @companies.present?
  @company_ids=@companies.collect(&:id).join(', ')
  @response_all = Response.find(:all,
     :select=>"responses.answer_1, questions.id, surveys.id",
     :joins =>"right outer join questions on (questions.id=responses.question_id and responses.survey_id=#{@survey.id})
              left outer join surveys on surveys.company_id in (#{@company_ids}) 
              left outer join sub_sections on questions.sub_section_id = sub_sections.id 
              inner join sections on sections.id = sub_sections.section_id",
     :group=>"surveys.id,responses.answer_1, questions.id",
     :order=>"questions.id"        
     )
  else
    @response_all = Response.find(:all,
     :select=>"count(*), responses.answer_1, questions.id",
     :joins =>"right outer join questions on (questions.id=responses.question_id and responses.survey_id=#{@survey.id})
              left outer join surveys on responses.survey_id = surveys.id 
              left outer join sub_sections on questions.sub_section_id = sub_sections.id 
              inner join sections on sections.id = sub_sections.section_id",
     :group=>"questions.id, responses.answer_1",
     :order=>"questions.id"    
     )
  end  
  
  GoogleChart::LineChart.new("900x330", "Overall", false) do |line_graph|
    line_graph.data "Your Response", @response.map(&:answer_1).collect{|i| i.to_i}, '00ff00'
    line_graph.data "Overall Response", @response_all.map(&:answer_1).collect{|i| i.to_i}, 'ff0000'
    line_graph.axis :y, :range =>[0,5], :labels =>[0,1,2,3,4,5], :font_size =>10, :alignment =>:center
    line_graph.axis :x, :range =>[0,@question_count], :font_size =>10, :alignment =>:center
    line_graph.show_legend = true
    line_graph.shape_marker :circle, :color => '0000ff', :data_set_index => 0, :data_point_index => -1, :pixel_size => 5
    line_graph.grid :x_step => 100.0/10, :y_step=>100.0/10, :length_segment =>1, :length_blank => 0
    @line_graph =  line_graph.to_url
  end
  return @line_graph
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

def self.get_average_calculated_score(response_survey_id, response_questions_id, section_id)
 @avg_response_score = 0
 total_score = 0
 survey = self.find(response_survey_id)
 company = Company.find(survey.company_id)
 
 company_all = Company.find(:all, :conditions=>"industry_id=#{company.industry.id} 
                                              and id !=#{company.id} ")
 if company_all
    response = Response.find(:all, :select =>"responses.id, responses.question_id, responses.answer_1",
               :joins=>"left outer join questions on questions.id = responses.question_id 
                        left outer join sub_sections on sub_sections.id = questions.sub_section_id
                        inner join sections on sections.id = sub_sections.section_id
                        where sections.id=#{section_id}")
    response.each do |res|
      @score =  get_individual_response_score(res.id, res.question_id)
      total_score += @score 
    end  
    avg_response_score = (total_score/response.count)
  end  
    return avg_response_score
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

