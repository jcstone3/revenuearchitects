class SurveyController < ApplicationController

#new survey
def new
	@survey = Survey.new
end	

#create new survey
def create
	@company = current_user.company.first
	@survey = @company.survey.create!(params[:survey])
	if @survey
	   flash[:notice] = "Survey created successfully"
	   redirect_to :action=>"question"
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
