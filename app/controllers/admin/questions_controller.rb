class Admin::QuestionsController < ApplicationController
   layout "admin"
	def index
		@question = Question.new
		@subsection = SubSection.find(:all, :order=>"id ASC")		
	end	

    def new
     # @question = Question.new
	 # @subsection = SubSection.find(:all, :order=>"id ASC")
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
