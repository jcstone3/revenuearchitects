class Survey < ActiveRecord::Base
	validates :size, :presence => true #,:numericality => {:greater_than => 0}
	validates :revenue, :presence => true #, :numericality => {:greater_than => 0}
	#validates :start_date, :presence => true
	#validates :end_date, :presence => true
  validates :company_id, :presence => true	
    
	belongs_to :company
	has_many :responses
  
   # default_scope :company_id == current_user.companies
   
   scope :get_all_survey_for_user, lambda{|company_ids|{   
    :conditions => "company_id in (#{company_ids})"  
   }}

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
    @responses = Response.get_response(section_id, surveyid) 
   return @responses
   end 

  def self.get_result_action(surveyid, action)
   @responses = Response.get_response_for_priority(surveyid, action)
   return @responses
   end 

  def self.get_section_graph(section_id, survey_id)
 #  require 'rubygems'
 # require 'google_chart'
 # @section = Section.find(section_id)   
 # @survey = Survey.find(survey_id)
 # @question_count = Question.find_question_count(section_id)
 # @response = Response.get_resultresponse(section_id, survey_id)
 #  @response_all = []
  
 #  #Average response for all survey
  
 #  @company = Company.find(@survey.company_id)  
 #  @companies = Company.get_all_companies(@company.id, @company.industry_id)
 #  if @companies.present?
 #  company_ids=@companies.collect(&:id).join(', ')
 #  @response_all = Response.get_overall_response_on_companies(company_ids, section_id, survey_id)
 #  else
 #    @response_all = Response.get_overall_response_without_companies(section_id, survey_id)
 #  end 
  
  
 #  GoogleChart::LineChart.new("900x330", "#{@section.name}", false) do |line_gph|
 #    line_gph.data "Your Response", @response.map(&:answer_1).collect{|i| i.to_i}, '00ff00'
 #    line_gph.data "Overall Response", @response_all.map(&:answer_1).collect{|i| i.to_i}, 'ff0000'
 #    line_gph.axis :y, :range =>[0,5], :labels =>[0,1,2,3,4,5], :font_size =>10, :alignment =>:center
 #    line_gph.axis :x, :range =>[0,@question_count.first.question_count], :font_size =>10, :alignment =>:center
 #    line_gph.show_legend = true
 #    line_gph.shape_marker :circle, :color => '0000ff', :data_set_index => 0, :data_point_index => -1, :pixel_size => 5
 #    line_gph.grid :x_step => 100.0/10, :y_step=>100.0/10, :length_segment =>1, :length_blank => 0
 #    @line_graph_programs =  line_gph.to_url
 #  end
 @survey = Survey.find(survey_id)
 @response = Response.get_resultresponse(section_id, survey_id)
    @questions = Question.find_section_questions(section_id)

  # Average response for all survey
  
  @company = Company.find(@survey.company_id)  
  @companies = Company.get_all_companies(@company.id, @company.industry_id)
  if @companies.present?
  company_ids=@companies.collect(&:id).join(', ')
  @response_all = Response.get_overall_response_on_companies(company_ids, section_id, survey_id)
  logger.debug "in with companies"
  else
    @response_all = Response.get_overall_response_without_companies(section_id, survey_id)
    logger.debug "in without companies"
  end 

    @data_table = GoogleVisualr::DataTable.new

    @data_table.new_column('string', 'Questions' )
    @data_table.new_column('number', 'Your Score')
    @data_table.new_column('number', 'Average Score')

     overall_array = Array.new
     response_array = Array.new

     @questions.each do |question|
        response_array = Array.new

      response_array.push(question.id.to_s)
      @your_response = @response.select { |response| response.question_id == question.id.to_i } 
      response_array.push(@your_response.first.answer_1.nil? ? 0 :  @your_response.first.answer_1.to_i)
      @avg_response = @response_all.select { |response| response.question_id == question.id.to_i }
      response_array.push(@avg_response.first.answer_1.nil? ? 0 : @avg_response.first.answer_1.to_i )
      overall_array.push(response_array)
      end

    # Add Rows and Values
    @data_table.add_rows(overall_array)

   return @data_table
  end  

#the overall graph 
def self.get_overall_graph(survey_id)
 
    @survey = Survey.find(survey_id)
    #current user response for the survey   
    @response = Response.get_response_for_all_sections(survey_id)
    
    @questions = Question.find(:all, :select => "id")
    
    #get all companies belonging to the industry as of the current user company industry 

    @company = Company.find(@survey.company_id)  
    @companies = Company.get_all_companies(@company.id, @company.industry_id)
   
    if @companies.present?
      company_ids=@companies.collect(&:id).join(', ')
      @response_all = Response.find_response_for_all_sections_company(company_ids,survey_id)
      logger.debug "in with companies"
    else
      @response_all = Response.find_response_for_sections_without_company(survey_id)
      logger.debug "in without companies"
    end  
     
    @data_table = GoogleVisualr::DataTable.new

    @data_table.new_column('string', 'Questions' )
    @data_table.new_column('number', 'Your Response')
    @data_table.new_column('number', 'Average Response')

     overall_array = Array.new
     response_array = Array.new

     @questions.each do |question|
        response_array = Array.new

      response_array.push(question.id.to_s)
      @your_response = @response.select { |response| response.id == question.id.to_i } 
      response_array.push(@your_response.first.answer_1.nil? ? 0 :  @your_response.first.answer_1.to_i)
      @avg_response = @response_all.select { |response| response.id == question.id.to_i }
      response_array.push(@avg_response.first.answer_1.nil? ? 0 : @avg_response.first.answer_1.to_i )
      overall_array.push(response_array)
      end

    # Add Rows and Values
    @data_table.add_rows(overall_array)

  return @data_table
end

  #total response for a section
  #TODO: Optimize this query
def self.calculate_response_for_section(survey_id, section_id)
    # questions = []  
    # @section = Section.find(section_id)
    # @section.sub_sections.each do |s|
    #  s.questions.each do |q|
    #    questions << q.id
    #  end
    # end
    # @survey = self.find(survey_id)
    # @sur_responses = @survey.responses.find_all_by_question_id(questions)   
    # calculate_response(@sur_responses)

    #Get all responses in this Survey/Section
    @section_responses = Response.select("responses.id as response_id, questions.points, responses.answer_1 ").joins(:survey, :question => [{:sub_section => :section}]).where("surveys.id = ? and sections.id = ? ", survey_id, section_id)

    #Get the responses, get score from question and multiply the point from response
    result = 0 
    if @section_responses.blank?
      result = 0
    else
      @section_responses.each do |response|
        result += get_score_value(response.points, response.answer_1)
        logger.debug "#{result}"
      end
     end
   
    return result
end   

#total response for a subsection
def self.calculate_response_for_subsection(survey_id, sub_section_id)
   
  result = 0 
  
  @sub_section_responses = Response.select("responses.id as response_id, questions.points, responses.answer_1 ").joins(:survey, :question => [{:sub_section => :section}]).where("surveys.id = ? and sub_sections.id = ? ", survey_id, sub_section_id)
  if @sub_section_responses.blank?
      result = 0
  else
    @sub_section_responses.each do |response|
     result +=  get_score_value(response.points, response.answer_1)
    end
  end 
  logger.debug "#{result} in subsection ##############}" 
  return result
  
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
 
 company_all = Company.get_companies_belonging_to_same_industry(company.industry.id,company.id)
 if company_all
    response = Response.find_average_response(section_id)
    response.each do |res|
      @score =  get_individual_response_score(res.id, res.question_id)
      total_score += @score 
    end  
    avg_response_score = (total_score/response.count)
  end  
    return avg_response_score
end    

#Get the Final Score for each answer
# This is new function. Use this
def self.get_score_value(question_points, response_score)
  logger.debug "Scoring the Response"
  score = 0 
  question_points_int = question_points.to_i
  response_score_int = response_score.to_i
  
  #calculation for score is (question_points * slider_percentage)/100
  #slider percentage will be -20, 0, 20, 60, 100 depending on the value of response_score
  response_percentage = 0
  case response_score_int
             when 1
               response_percentage = -20
             when 2
               response_percentage = 0
             when 3
               response_percentage = 20
             when 4
               response_percentage = 60
             when 5
               response_percentage = 100
             end 
 
  # individual response score calculation will be 
  score = (question_points_int * response_percentage)/100
     
  return score 
end


#individual score for each response
def self.get_individual_response_score(response_id, response_question_id)
  score = 0
  question = Question.find(response_question_id)
  response = Response.find(response_id)
  #for each response calculate the response score
  score = get_score_value(question.points, response.answer_1)
  return score
end


end
# == Schema Information
#
# Table name: surveys
#
#  id         :integer         not null, primary key
#  company_id :integer
#  size       :string(255)
#  revenue    :string(255)
#  start_date :date
#  end_date   :date
#  is_active  :boolean
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

