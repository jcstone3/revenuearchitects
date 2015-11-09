class Admin::SectionController < ApplicationController
   layout "admin"
	def index
    @sections =  Section.find(:all,
                       :select => "sub_sections.id as subsection_id, sections.name, sub_sections.name as subsection_name, sub_sections.description as subsection_desc",
                       :joins => "left outer join sub_sections on sections.id = sub_sections.section_id WHERE sub_sections.deleted_at IS NULL",
                       :order =>"sections.id ASC")
	  #@sections = Section.all(:order=>"id ASC")
    #@sub_sections = SubSection.all(:order=>"id ASC")
	end

    def new
      @section = Section.new
    end

    def create
      @section = Section.new(params[:section])
      @section.sequence = Section.last_secuence
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
    end

    def create_subsection
    	params[:sub_section].merge!(:is_active => true, :sequence => SubSection.last_secuence)
    	@subsection = SubSection.new(params[:sub_section])
    	if @subsection.save
      	 flash[:success] = "Sub Section created successfully!"
      	 redirect_to admin_sections_url
        else
          @sections = Section.all
         flash[:error] = "Section could not be created"
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
      if @subsection.update_attributes(params[:sub_section])
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


    def reports_index
    end

	  def destroy_subsection
      @subsection = SubSection.find_by_id(params[:id])

      if @subsection.destroy
         flash[:message] = "Subsection deleted successfully"
      else
        flash[:message] = "Sorry could not delete subsection"
      end

    redirect_to :action => 'index'
  end

    def details_subsection
      @subsection = SubSection.find_by_id(params[:id])
       @question =  Question.unscoped.find(:all,
                       :select => "questions.id as question_id, questions.position as question_position, questions.points as question_points, sub_section_id as subsection_id, sub_sections.name, questions.name as question_name, questions.description as question_desc",
                       :joins => "left outer join sub_sections on sub_sections.id = questions.sub_section_id where questions.sub_section_id = #{params[:id]} and questions.deleted_at is NULL"
                               )

    end

end
