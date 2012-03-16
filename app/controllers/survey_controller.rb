class SurveyController < ApplicationController



#new survey
def new
	@survey = Survey.new
end	

#create new survey
def create
	@company = current_user.companies.first
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
	@question = Question.find(params[:question_id])
	@response = Response.new
end	

def create_response
	@response = Response.new
	@survey = Survey.find(params[:id])
	params[:response].merge!(:question_id => params[:question_id], :answer_1 => params[:answer_1], :name =>params[:response][:answer_2])
	@response = @survey.responses.create!(params[:response])
	redirect_to questions_url(@survey, params[:question_id].to_i+1 )
end

#report of a particular survey
def report	
end	

def previous_question
	@survey = Survey.find(params[:id])
	@question = Question.find_by_survey_id_and_question_id(params[:id], params[:question_id])
end

def update_question
   
end

end
