class CompaniesController < ApplicationController
	before_filter :authenticate_user!
  # before_filter :redirect_path_for_user

	layout "application"

	def index
	end

    #new#company
	def new
    @user = current_user;
		@company = Company.new
		#@industries = Industry.all
	end

	#crating new company
	def create
  	@company = Company.new(params[:company])
    @company.user = current_user
    @user = current_user
  	if @company.valid? && @user.update_attributes(params[:user])
      @company.save
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
    @user = current_user;
  end

  def update
    @company = Company.find_by_id(params[:id])
    @user = current_user
    
    if @user.update_attributes(params[:user] && @company.update_attributes(params[:company]))
      # On comapany updation redirects to the update survey
      if @user.is_permanent?
        redirect_to edit_survey_path(id: session[:survey])
      else
        render :new
      end
    else
      render :edit
    end
  end
end
