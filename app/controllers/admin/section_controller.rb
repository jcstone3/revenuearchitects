class Admin::SectionController < ApplicationController

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
        flash[:success] = "Section Added successfully!"	
        render :new
      end 
    end	

    def subsection_new
      @subsection = SubSection.new
    end
    	
    def subsection_create
    	@subsection = SubSection.new(params[:subsection])
    end

	def reports_index
	end	
end
