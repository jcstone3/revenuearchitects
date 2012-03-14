class CompaniesController < ApplicationController
	layout "application"

	def index
	end	

    #new#company
	def new
		@company = Company.new
	end
	
	def create
	end

   #edit#company
    def edit
    end
    
    def update
    end
end
