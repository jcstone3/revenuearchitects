class Admin::SectionController < ApplicationController
   layout "admin"
	def index
    @sections =  Section.find(:all,
                       :select => "sub_sections.id as subsection_id, sections.name, sub_sections.name as subsection_name, sub_sections.description as subsection_desc",
                       :joins => "left outer join sub_sections on sections.id = sub_sections.section_id",
                       :order =>"sections.id ASC")
	  #@sections = Section.all(:order=>"id ASC")
    #@sub_sections = SubSection.all(:order=>"id ASC")
	end

    def new
      @section = Section.new
	  #@sub_section = SubSection.new
    end

    def create
      @section = Section.new(params[:section])  
      @last_section = Section.last
      @section.sequence = @last_section.sequence.to_i + 1
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
    	params[:sub_section].merge!(:is_active=>true)
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

    # def edit_section
    #   @section = Section.find_by_id(params[:id])
    #   logger.debug "@section.inspect"
    # end  

    def edit_subsection
      @subsection = SubSection.find_by_id(params[:id])
    end  

    # def update_section
    #   @section = Section.find_by_id(params[:id])
    #   if @section.update_attributes(params[:section])
    #      flash[:success] = "Section updated successfully"
    #      redirect_to admin_sections_url
    #   else
    #     flash[:error] = "Section could not be updated"
    #      render :edit
    #   end 
    # end

    def update_subsection
      @subsection = SubSection.find_by_id(params[:id])
      if @subsection.update_attributes(params[:subsection])
         flash[:success] = "SubSection updated successfully"
         redirect_to admin_sections_url
      else
         flash[:error] = "SubSection could not be updated"
         render :edit_subsection
      end 
    end  

    # def destroy_section
    #   @section = Section.find_by_id(params[:id])
    #    if @section.destroy
    #   flash[:success] = "Section Created successfully"         
    # else
    #   flash[:success] = "Section not Created successfully"          
    # end   
    #  redirect_to :action => 'index' 
    # end

    def destroy_subsection
      @subsection = SubSection.find_by_id(params[:id])
       if @subsection.destroy
      flash[:success] = "SubSection Created successfully"         
    else
      flash[:success] = "SubSection not Created successfully"          
    end   
     redirect_to :action => 'index' 
    end


	  def reports_index
  	end	


end
