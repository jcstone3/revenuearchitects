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
    	
    def create_subsection
    	params[:sub_section].merge!(:section_id=>params[:section_id], :is_active=>true)
    	@subsection = SubSection.new(params[:sub_section])
    	if @subsection.save    	
      	 flash[:success] = "Sub Section Added successfully!"
      	 redirect_to admin_sections_url
        else
          @sections = Section.all	
         flash[:error] = "Section could not be added"	
         render :subsection_new
        end 
    end

	def reports_index
	end	
end
