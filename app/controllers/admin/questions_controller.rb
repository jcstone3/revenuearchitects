class Admin::QuestionsController < ApplicationController
   layout "admin"
	def index
		#@question = Question.new
    @questions = Question.paginate(:page=> params[:page], :per_page=>10)
   @questions  =  Question.find(:all,
                       :select => "questions.name, questions.description, questions.points, sub_sections.name as subsection_name, sections.name as section_name",
                       :joins => "left outer join sub_sections on questions.sub_section_id = sub_sections.id left outer join
                                  sections on sections.id = sub_sections.section_id")

		#@subsection = SubSection.find(:all, :order=>"id ASC")		
	end	

    def new
      @question = Question.new
	    @subsection = SubSection.find(:all, :order=>"id ASC")
    end	

	def create
		params[:question].merge!(:sub_section_id => params[:sub_section_id])
		@question = Question.new(params[:question])		
        if @question.save
          flash[:success] = "Question Created successfully"
          redirect_to :action => 'index'
        else
          flash[:error] = "Question could not be created"
         render :index
        end 
	end	
end
