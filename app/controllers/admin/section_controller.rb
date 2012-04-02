class Admin::SectionController < ApplicationController
   layout "admin"
	def index
	  @sections = Section.all
      @sub_sections = SubSection.all
	end

    def new
      @section = Section.new
	  #@sub_section = SubSection.new
    end

    def create
      @section = Section.new(params[:section])  
      if @section.save    	
      	flash[:success] = "Section Added successfully!"
      	redirect_to admin_sections_url
      else
        flash[:error] = "Section could not be added"	
        render :new
      end 
    end	

    def subsection_new
      @subsection = SubSection.new
      @sections = Section.all
    end
    	
    def subsection_create
    	@subsection = SubSection.new(params[:subsection])
    	if @subsection.save    	
      	 flash[:success] = "Sub Section Added successfully!"
      	 redirect_to admin_sections_url
        else
         flash[:error] = "Section could not be added"	
         render :subsection_new
        end 
    end

	def reports_index
	end	
end
