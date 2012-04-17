class Admin::QuestionsController < ApplicationController
   layout "admin"
	def index
		#@question = Question.new
    @questions = Question.paginate(:page=> params[:page], :per_page=>10)
   @questions  =  Question.find(:all,
                       :select => "questions.name, questions.description, questions.id, questions.points, sub_sections.name as subsection_name, sections.name as section_name",
                       :joins => "left outer join sub_sections on questions.sub_section_id = sub_sections.id left outer join
                                  sections on sections.id = sub_sections.section_id",
                       :order => "questions.id ASC"          )

				
	end	

    def new
      @question = Question.new
	    @subsection = SubSection.find(:all, :order=>"id ASC")
    end	

	def create
		params[:question].merge!(:sub_section_id => params[:sub_section_id])
		@question = Question.new(params[:question])		
        if @question.save
          @sub_section = SubSection.find(@question.sub_section_id)
          @section = Section.find(@sub_section.section_id)
          @section_question = @section.question_count += 1
          @section_total = @section.total_points += @question.points
          if @section.update_attributes(:question_count => @section_question ,:total_points => @section_total)
          flash[:success] = "Question Created successfully"
          redirect_to :action => 'index'
          else
            flash[:success] = "Question Created successfully"
            redirect_to :action => 'index'
          end  
        else
          flash[:error] = "Question could not be created"
         render :index
        end 
	end	
 
 def edit  
    @question = Question.find_by_id(params[:id])
    @subsection = SubSection.find(:all, :order=>"id ASC")
    respond_to do |format|
      format.html
    end  
  end

  def update
   @question = Question.find(params[:id])
   params[:question].merge!(:sub_section_id => params[:sub_section_id])   

    if @question.update_attributes(params[:question])
      flash[:success] = "Question Created successfully"
          redirect_to :action => 'index'
    #format.html (redirect_to (@question))
    else 
      @subsection = SubSection.find(:all, :order=>"id ASC")
      flash[:error] = "Question could not updated"
      render :action => 'edit'
   
   end 
  end

  def destroy
    @question = Question.find(params[:id])
    if @question.destroy
      flash[:success] = "Question Created successfully"         
    else
      flash[:success] = "Question Created successfully"          
    end   
     redirect_to :action => 'index'   
  end

 
end
