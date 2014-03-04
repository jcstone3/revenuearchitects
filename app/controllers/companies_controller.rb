class CompaniesController < ApplicationController
	before_filter :authenticate_user!
  # before_filter :redirect_path_for_user

	layout "application"

	def index
	end

    #new#company
	def new
		@company = Company.new
		#@industries = Industry.all
	end

	#crating new company
	def create
  	@company = Company.new(params[:company])
    @company.user = current_user
  	if @company.save
  		flash[:success] = "Company #{@company.name} created successfully"
  		redirect_to new_survey_url
  	else
  	  # flash[:error] = "Sorry could not create company"
  	  render :new
  	end
	end

  def show
  end

  #edit#company
  def edit
    @company = Company.find_by_id(params[:id])
  end

  def update
    @company = Company.find_by_id(params[:id])
    if @company.update_attributes(params[:company])
      # On comapany updation redirects to the update survey
      redirect_to edit_survey_path(id: session[:survey])
    else
      redirect_to edit_company_path
    end
  end
end
