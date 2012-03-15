class SurveyController < ApplicationController

def show
end

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
	   redirect_to question_url
	else
	   flash[:error] = "Sorry could not create the survey"
	   render "new"
	end       	
end

#question for the survey	
def question
end	

#report of a particular survey
def report
end	
end
