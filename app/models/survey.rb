class Survey < ActiveRecord::Base
	# validates :size, :presence => {:message => "Company size can't be blank"},:numericality => {:greater_than => 0}, on: :update
	# validates :revenue, :presence => {:message => "Company Revenue can't be blank"}, :numericality => {:greater_than => 0}, on: :update

  validates :size, :presence => {:message => "Company size can't be blank"}, on: :update
  validates :revenue, :presence => {:message => "Company Revenue can't be blank"}, on: :update


	#validates :start_date, :presence => true
	#validates :end_date, :presence => true
  validates :company_id, :presence => true

	belongs_to :company
	has_many :responses

   # default_scope :company_id == current_user.companies

   scope :get_all_survey_for_user, lambda{|company_ids|{
    :conditions => "company_id in (#{company_ids})",
    :order => "created_at DESC"
    }}

  def company_name
    (company)? company.name : ''
  end

  def date_format
    created_at.strftime('%^B %Y')
  end

    def self.to_csv(options = {})
      CSV.generate(options) do |csv|
        csv << column_names
        all.each do |survey|
          csv << survey.attributes.values_at(*column_names)
        end
      end
    end

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

  def self.get_section_graph(section_id, survey_id, responses)
   #responses - your response for the current survey
   logger.debug responses.inspect
   logger.debug "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
   @survey = Survey.find(survey_id)
   #@response = Response.get_resultresponse(section_id, survey_id)
   @questions = Question.find_section_questions(section_id)

    # Average response for all survey

    @company = Company.find(@survey.company_id)
    @companies = Company.get_all_companies(@company.id, @company.industry_id)
    # if @companies.present?
    # company_ids=@companies.collect(&:id).join(', ')
    # @response_all = Response.get_overall_response_on_companies(company_ids, section_id, survey_id)
    # logger.debug "in with companies"
    # else
    #   @response_all = Response.get_overall_response_without_companies(section_id, survey_id)
    #   logger.debug "in without companies"
    # end



      @data_table = GoogleVisualr::DataTable.new

      @data_table.new_column('string', 'Practices' )
      @data_table.new_column('number', 'Your Score')
      @data_table.new_column('number', 'Average Score')

       overall_array = Array.new
       response_array = Array.new

       @questions.each do |question|
          response_array = Array.new

        response_array.push(question.id.to_s)
        logger.debug question.id

        @your_response = responses.select { |response| response.questions_id.to_i == question.id.to_i }


        Rails.logger.debug @your_response.inspect
        Rails.logger.debug "response array above!!!!!!!!!!!!!!!!!!!!!!!!!"
        response_array.push(@your_response.blank? ? 0 :  @your_response.first.score.to_i)

        #@your_response contains the users response value
        #call the helper method that calculated the avgerage value for this question
        #with other user responses for the same industry
        #@get_avg_response will have the avg calculated values for this question

        @get_avg_response = self.get_average_score_from_other_companies(question.id,survey_id)

        logger.debug "&&&&& average response for section graph"
        logger.debug "question is #{question.id} - average score is #{@get_avg_response}"

        #@avg_response = @response_all.select { |response| response.question_id == question.id.to_i }

        response_array.push(@get_avg_response)
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

    @questions = Question.find(:all, :select => "*", :order => "id ASC")

    #get all companies belonging to the industry as of the current user company industry

    @company = Company.find(@survey.company_id)
    @companies = Company.get_all_companies(@company.id, @company.industry_id)

    # if @companies.present?
    #   company_ids=@companies.collect(&:id).join(', ')
    #   @response_all = Response.find_response_for_all_sections_company(company_ids,survey_id)
    #   logger.debug "in with companies"
    # else
    #   @response_all = Response.find_response_for_sections_without_company(survey_id)
    #   logger.debug "in without companies"
    # end

    @data_table = GoogleVisualr::DataTable.new

    @data_table.new_column('string', 'Practices' )
    @data_table.new_column('number', 'Your Response')
    @data_table.new_column('number', 'Average Response')

     overall_array = Array.new
     response_array = Array.new

     @questions.each do |question|
     response_array = Array.new

      #get section id for each question
      section_id = question.sub_section.section.id

      response_array.push(question.id.to_s)

      @your_response = @response.select { |response| response.id == question.id.to_i }
      response_array.push(@your_response.blank? ? 0 :  @your_response.first.answer_1.to_i)


      @avg_response = self.get_average_score_from_other_companies(question.id,survey_id)

      response_array.push(@avg_response)
      overall_array.push(response_array)
      end

    # Add Rows and Values
    @data_table.add_rows(overall_array)

  return @data_table
end


# overall chart data
def self.get_overall_data(survey_id)
    @response = Response.get_response_for_all_sections(survey_id)
    @questions = Question.find(:all, :select => "*", :order => "id ASC")

    @data_table = Array.new
    @resp_array = Array.new
    @your_array = Array.new
    @avg_array = Array.new

    @questions.each do |question|

      @your_response = @response.select { |response| response.id == question.id.to_i }

      @resp_array.push(question.id.to_s)
      @your_array.push(@your_response.blank? ? 0 :  @your_response.first.answer_1.to_i)
      @avg_array.push(self.get_average_score_from_other_companies(question.id,survey_id))

    end

    @data_table.push(@resp_array)
    @data_table.push(@your_array)
    @data_table.push(@avg_array)

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
    @section_responses = Response.select("responses.id as response_id, questions.points, responses.answer_1 ").joins(:survey, :question => [{:sub_section => :section}]).where("surveys.id = ? and sections.id = ? and responses.answer_2 !=?", survey_id, section_id, "not_applicable")

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

def self.calculate_score_for_section(survey_id)
  @point_per_question = Section.find(:all, :select => "sections.id as section, questions.points as points, responses.answer_1 as answer_1", :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id left outer join responses on (responses.question_id = questions.id)", :conditions =>  "responses.survey_id =#{survey_id}")

  @score_strategy = 0
  @score_system = 0
  @score_program = 0
  nums = 0
  if @point_per_question.blank?
    @score_strategy = 0
    @score_system = 0
    @score_program = 0
    nums = 0
  else
    @point_per_question.each do |response|
      @all_sections = Section.all
      if response.section.to_i == @all_sections[0].id
        @score_strategy += get_score_value(response.points, response.answer_1)
      elsif response.section.to_i == @all_sections[1].id
        @score_system += get_score_value(response.points, response.answer_1)
      elsif response.section.to_i == @all_sections[2].id
        @score_program += get_score_value(response.points, response.answer_1)
      end
    end
    nums = Array[@score_strategy,@score_system,@score_program]
    return nums
  end
end

#total response for a subsection
def self.calculate_response_for_subsection(survey_id, sub_section_id)

  result = 0

  @sub_section_responses = Response.select("responses.id as response_id, questions.points, responses.answer_1 ").joins(:survey, :question => [{:sub_section => :section}]).where("surveys.id = ? and sub_sections.id = ? and responses.answer_2 !=?", survey_id, sub_section_id, "not_applicable")
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
 avg_response_score = 0
 total_score = 0
 survey = self.find(response_survey_id)
 company = Company.find(survey.company_id)
 industry_id = company.industry_id
 company_all = Company.get_companies_belonging_to_same_industry(industry_id)
 if !company_all.blank?

    company_ids=company_all.collect(&:id).join(', ')

     # response = Response.find_average_response(section_id,response_survey_id,industry_id)
   response = Response.find_response_from_other_companies(response_questions_id, response_survey_id,company_ids,industry_id)
    response.each do |res|
      @score =  get_individual_response_score(res.id, res.question_id)
      total_score += @score
    end
    response_count = response.count
    avg_response_score = (total_score/response_count) if response_count > 0
  end
    return avg_response_score
end

#calculation average score for questions from other companies
def self.get_average_score_from_other_companies(response_questions_id, response_survey_id)
  #first check current user company and industry
  #get other companies belonging to same company
  #get question score from other companies
  #calculate the average
  @avg_response_score = 0
  @total_average_score = 0
  survey = self.find(response_survey_id)
  company = Company.find(survey.company_id)
  industry_id = company.industry_id
  company_all = Company.get_companies_belonging_to_same_industry(company.industry_id)
  if company_all.present?
    company_ids=company_all.collect(&:id).join(', ')
    @responses = Response.find_response_from_other_companies(response_questions_id, response_survey_id,company_ids,industry_id)
    if @responses.present?
      @responses.each do |response|
        @total_average_score += response.answer_1
      end

      response_count = @responses.count
      @total_average_score = @total_average_score/response_count if response_count > 0
    end
  end
  return @total_average_score
end

#Get the Final Score for each answer
# This is new function. Use this
def self.get_score_value(question_points, response_score)
  logger.debug "Scoring the Response"
  score = 0
  question_points_int = question_points.to_i
  response_score_int = response_score.to_i

  #calculation for score is (question_points * slider_percentage)/100
  #slider percentage will be -20, -10, 0, 20, 30 depending on the value of response_score
  response_percentage = 0
  case response_score_int
             when 1
               response_percentage = 10
             when 2
               response_percentage = 40
             when 3
               response_percentage = 60
             when 4
               response_percentage = 80
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
  question = Question.unscoped.find(response_question_id)
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
