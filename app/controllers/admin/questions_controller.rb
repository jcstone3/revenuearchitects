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
		@question = Question.new(params[:question])		
        if @question.save
         #find the section for the subsection to increase the count of the 
         #the questions added to that section          
         @section = Section.find_by_sql("select * from sections inner join sub_sections on sections.id = sub_sections.section_id and sub_sections.id = #{@question.sub_section_id}")
         @section_question_count = @section.first.question_count += 1
         @section_total_points = @section.first.total_points + @question.points
        
         if @section.first.update_attributes(:question_count => @section_question_count ,:total_points => @section_total_points)
          flash[:success] = "Question Created successfully"
         redirect_to :action => 'index'
         else
           flash[:success] = "Question could not successfully"
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
   
    if @question.update_attributes(params[:question])
      #get questions count and questions total point for each section 
       @questions =   Question.find(:all, :select => "sum(questions.points) as question_points, count(*) as question_count, sections.name", :joins => "left join sub_sections on questions.sub_section_id = sub_sections.id inner join sections on sections.id = sub_sections.section_id", :group => "sections.name")
       @sections = Section.all

        @sections.each_with_index do |section, i|
          section.update_attributes(:total_points=> @questions[i].question_points, :question_count=>@questions[i].question_count)
        end 
         
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
