class CompaniesController < ApplicationController
	layout "application"

	def index
	end	

    #new#company
	def new
		@company = Company.new
		@industry = Industry.all
	end
	
	#crating new company
	def create
		@company = current_user.companies.create!(params[:company])
		if @company
			flash[:notice] = "Company created successfully"
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
    end
    
    def update
    end
end
