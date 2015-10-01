class Admin::QuestionsController < ApplicationController
   layout "admin"
	def index
		#@question = Question.new
    @questions = Question.paginate(:page=> params[:page], :per_page=>10)
    @questions  =  Question.find(:all,
                       :select => "questions.id, questions.position, questions.name, questions.description, questions.id, questions.points, sub_sections.name as subsection_name, sections.name as section_name",
                       :joins => "left outer join sub_sections on questions.sub_section_id = sub_sections.id left outer join
                                  sections on sections.id = sub_sections.section_id",
                       :order => "questions.position ASC")

				
	end	

    def new
      @question = Question.new	
      @subsections = SubSection.all    
    end	

	def create	
    params[:question].merge!(:sequence => Question.last_secuence)
		@question = Question.new(params[:question])	

        if @question.save
         #find the section for the subsection to increase the count of the 
         #the questions added to that section          
         logger.debug @question
         @section = Section.find_by_sql("select sections.id, sections.name , sections.questionnaire_id, question_count, total_points, sub_sections.id as sub_section_id from sections inner join sub_sections on sections.id = sub_sections.section_id and sub_sections.id = #{@question.sub_section_id}")

         @section_question_count = @section.first.question_count += 1
         @section_total_points = @section.first.total_points + params[:question][:points].to_i
        
         if @section.first.update_attributes(:question_count => @section_question_count ,:total_points => @section_total_points)
          flash[:success] = "Question Created successfully"
         redirect_to :action => 'index'
         else
           flash[:success] = "Question could not be created successfully"
           redirect_to :action => 'index'
         end  
        else
          flash[:error] = "Question could not be created"
          render 'new'
        end 
	end	
 
 def edit  
    @question = Question.find_by_id(params[:id])    
    respond_to do |format|
      format.html
    end  
  end

  def update
   @question = Question.find(params[:id])
   
    if @question.update_attributes(params[:question])
      #get questions count and questions total point for each section 
       @questions =   Question.find(:all,
                                    :select => "sum(questions.points) as question_points, count(*) as question_count, sections.name", 
                                    :joins => "left join sub_sections on questions.sub_section_id = sub_sections.id right outer join sections on sections.id = sub_sections.section_id",
                                    :group => "sections.name,sections.id",
                                    :order => "sections.id")
       logger.debug @questions.inspect
       @sections = Section.all(:order=>'sections.id')
       logger.debug @sections
        @sections.each_with_index do |section, i|
          section.update_attributes(:total_points=> @questions[i].question_points, :question_count=>@questions[i].question_count)
          logger.debug section
        end 
        
      flash[:success] = "Question Updated successfully"
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
      flash[:success] = "Question Deleted successfully"         
    else
      flash[:success] = "Question couldn't be deleted"          
    end   
     redirect_to :action => 'index'   
  end

 
end
