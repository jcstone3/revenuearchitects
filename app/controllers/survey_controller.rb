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

def add_response
end

#report of a particular survey
def report	
end	

end
