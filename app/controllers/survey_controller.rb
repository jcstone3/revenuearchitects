class SurveyController < ApplicationController

before_filter :authenticate_user!
before_filter :check_company

#new survey
def new
  #if any active survey exists then user will get redirected to the active survey questions
  @active_survey = current_user.companies.first.surveys.find(:first, :conditions=>["is_active=?", true])
	if @active_survey
   @response = @active_survey.responses.last 
   if  @response
     redirect_to questions_url(@active_survey, @response.question_id+1)
   else
     redirect_to questions_url(@active_survey, 1)
   end
  else
   #start with a new survey
   @previous_surveys = current_user.companies.first.surveys.find(:all, :conditions=>["is_active=?", false])
   @survey = Survey.new
  end 
end	

#create new survey
def create
	@company = current_user.companies.first
  params[:survey].merge!(:start_date => Time.now, :is_active => true)
	@survey = @company.surveys.create!(params[:survey])
	if @survey
	   flash[:notice] = "Survey created successfully"
	   redirect_to questions_url(@survey, 1)
	else
	   flash[:error] = "Sorry could not create the survey"
	   render "new"
	end       	
end

#question for the survey	
def question	
	@survey = current_user.companies.first.surveys.find_all_by_id(params[:id])	
	if @survey
      @question = Question.find(params[:question_id])     
      if @question 
         @survey_response = Response.find_last_by_survey_id_and_question_id(params[:id], params[:question_id])
         if @survey_response
            redirect_to previous_question_url(params[:id], params[:question_id])
         else   
            @sub_section = SubSection.find(@question.sub_section_id)
            @section = Section.find(@sub_section.section_id)
            @allSection = Section.all
            @response = Response.new
            @total_score = calculate_response_for_section(params[:id], @section.id)
         end
      else
        redirect_to  new_survey_path  
      end      
  else
    new_survey_path 	
  end
end	

def create_response
	@response = Response.new
	@survey = Survey.find(params[:id])
	params[:response].merge!(:question_id => params[:question_id], :name =>params[:response][:answer_2])	
	@response = @survey.responses.create!(params[:response])	
  @question = Question.find(@response.question_id)
	@sub_section = SubSection.find(@question.sub_section_id)
	@section = Section.find(@sub_section.section_id)
	@total_score = calculate_response_for_section(params[:id], @section.id)
	redirect_to questions_url(@survey, params[:question_id].to_i+1)
end

#report of a particular survey
def report
  @survey = Survey.find(params[:id])
  @section_total = []
  @subsection_total = []
  @questions_score = []	
  @questions_score = []  
  @sections = Section.find(:all) 
  #score for each section and subsection
  @sections.each do |section|
     @section_total << calculate_response_for_section(params[:id], section.id)
     section.sub_sections.each do |sub_section|     
     @subsection_total << calculate_response_for_subsection(params[:id], sub_section.id)
    end
  end
  @final_score = @section_total[0]+@section_total[1]+@section_total[2]
  #get the individual response score
  @survey.responses.each do |response|
    @questions_score << get_individual_response_score(response.id, response.question_id)
  end  
  
  render :layout =>"reports"
end	

def previous_question
	@survey = Survey.find(params[:id])
	@question = Question.find(params[:question_id])
	if @question
    @survey_response = Response.find_by_question_id(params[:question_id])
    if @survey_response
      @sub_section = SubSection.find(@question.sub_section_id)
  	  @section = Section.find(@sub_section.section_id)
  	  @allSection = Section.all
  	  @response = Response.find_by_survey_id_and_question_id(params[:id], params[:question_id])	
  	  @total_score = calculate_response_for_section(params[:id], @section.id)
    else
     @response = @survey.responses.last 
     redirect_to questions_url(@survey, @response.question_id.to_i+1) 
  end 
  else
    @response = @survey.responses.last 
    redirect_to questions_url(@survey, @response.question_id.to_i+1) 
  end 
end


def reports2131
@survey = Survey.find(1)
  @section_total = []
  @subsection_total = []
  @questions_score = [] 
  @questions_score = []  
  @sections = Section.find(:all) 
  #score for each section and subsection
  @sections.each do |section|
     @section_total << calculate_response_for_section(section.id)
     section.sub_sections.each do |sub_section|     
     @subsection_total << calculate_response_for_subsection(@survey.id, sub_section.id)
    end
  end
  @final_score = @section_total[0]+@section_total[1]+@section_total[2]
  #get the individual response score
  @survey.responses.each do |response|
    #@questions_score << get_individual_response_score(response.id, response.question_id)
  end  
end

def update_response
   @survey = Survey.find(params[:id])
   @question = Question.find(params[:question_id])   	
   @response = Response.find_by_survey_id_and_question_id(params[:id], params[:question_id])
   params[:response].merge!(:name =>params[:response][:answer_2])
   @response.update_attributes(params[:response])
   @survey_response = Response.find_last_by_survey_id(params[:id])
   @sub_section = SubSection.find(@question.sub_section_id)
   @section = Section.find(@sub_section.section_id)
   @total_score = calculate_response_for_section(params[:id], @section.id)
   redirect_to questions_url(@survey, @survey_response.question_id.to_i+1 )
end

def download_result
  require 'spreadsheet'
  @questions_score = []
  @sections = Section.all 
  @survey = Survey.find(params[:id])
  @survey.responses.each do |response|
    @questions_score << get_individual_response_score(response.id, response.question_id)
  end
  respond_to do |format|
      format.pdf {
        html = render_to_string(:layout => false , :action => "show.html")
        kit = PDFKit.new(html)
        #kit.stylesheets << "#{Rails.root}/public/stylesheets/screen.css"
        send_data(kit.to_pdf, :filename => "survey.pdf", :type => 'application/pdf')
        return # to avoid double render call
      }

      
  end    
end


private
def check_company
  if !current_user.companies.first
     redirect_to new_company_url
  end
end	

#total response for a section
def calculate_response_for_section(survey_id, section_id)
	questions = []	
	@section = Section.find(section_id)
	@section.sub_sections.each do |s|
     s.questions.each do |q|
       questions << q.id
     end
	end
  @survey = Survey.find(survey_id)
	@sur_responses = @survey.responses.find_all_by_question_id(questions)	
	calculate_response(@sur_responses)
end	

#total response for a subsection
def calculate_response_for_subsection(survey_id, sub_section_id)
  questions = []  
  @sub_section = SubSection.find(sub_section_id)
  @sub_section.questions.each do |q|
       questions << q.id
  end
  @survey = Survey.find(survey_id)
  @sur_responses = @survey.responses.find_all_by_question_id(questions) 
  calculate_response(@sur_responses)
end 

#calculate response 
def calculate_response(survey_response)  
  @total_score = 0 
  survey_response.each do |response|
    @score = 0
    @score = get_individual_response_score(response.id, response.question_id)    
    @total_score += @score 
  end
    return @total_score
 end

#individual score for each response
def get_individual_response_score(response_id, response_question_id)
  score = 0
  question = Question.find(response_question_id)
  response = Response.find(response_id)
  case question.points
        when 5 
          if response.answer_1 == "1"
            score = -1            
          end
           if response.answer_1 == "2"
            score = 0
          end 
           if response.answer_1 == "3"
            score = 1
          end
           if response.answer_1 == "4"
            score = 3
          end
           if response.answer_1 == "5"
            score = 5
          end         

       when 10 
          if response.answer_1 == "1"
            score = -2
          end
           if response.answer_1 == "2"
            score = 0
          end 
           if response.answer_1 == "3"
            score = 2
          end
           if response.answer_1 == "4"
            score = 6
          end
           if response.answer_1 == "5"
            score = 10
          end          

        when 20 
          if response.answer_1 == "1"
            score = -4
          end
           if response.answer_1 == "2"
            score = 0
          end 
           if response.answer_1 == "3"
            score = 4
          end
           if response.answer_1 == "4"
            score = 12
          end
           if response.answer_1 == "5"
            score = 20
          end
        end        
       return score
end

 
end
