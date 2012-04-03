class SurveyController < ApplicationController

before_filter :authenticate_user!, :check_company #check current_user & company
 
layout "application"

#new survey
def new
  @active_survey = []
  @previous_surveys = []
  if current_user.companies.present?#if no company details is provided
        if check_existing_surveys #check if there exists previous surveys
            current_user.companies.each do |cmpany|
              @active_survey << cmpany.surveys.find(:all, :conditions=>["is_active=?", true])
            end
            flash[:notice] = "Please select survey to continue"
            redirect_to continue_survey_url               
        else
          #list all the previous completed surveys & start a new survey
          current_user.companies.each do |cmpany|
            @previous_surveys << cmpany.surveys.find(:all, :conditions=>["is_active=?", false])
          end       
          @survey = Survey.new
        end  
  else
    flash[:error] = "Please provide company details before proceeding"
    redirect_to new_company_url  
  end
end	

#create new survey
def create  
  @company = current_user.companies.first
  params[:survey].merge!(:start_date => Time.now, :is_active => true)
	@survey = @company.surveys.create!(params[:survey])
	if @survey
	   flash[:success] = "Survey created successfully"
	   redirect_to questions_url(@survey, 1)
	else
	   flash[:error] = "Sorry could not create the survey"
	   render "new"
	end       	
end

def get_response_status
  if params[:id].present?
    if params[:id].to_i > 0
    if params[:id].to_i.is_a?(Numeric)
          if check_user_surveys(params[:id])
              response = []
              questions= []

              @survey = Survey.find(params[:id])
              @response = @survey.responses
              if @response.present?
                 @response.each do |res|
                   response << res.question_id   
                 end 
                 Question.all.each do |quest|
                   questions << quest.id
                 end
                  res = questions - response
                 flash[:success] = "Continue Survey" 
                 redirect_to questions_url(@survey, res[0]) 
              else
               flash[:success] = "Start Survey" 
               redirect_to questions_url(@survey, 1)   
              end
          else
            flash[:error] = "Some thing went wrong please select a survey"
            redirect_to continue_survey_url 
          end      
  else
    flash[:error] = "Something went wrong please select a survey"
    redirect_to continue_survey_url
  end 
   else
    flash[:error] = "Something went wrong please select a survey"
    redirect_to continue_survey_url
  end 
  else
    flash[:error] = "Something went wrong please select a survey"
    redirect_to continue_survey_url 
 end
end

#lists all the active surveys 
def show
  @companies =  current_user.companies          
end  

#question for the survey	
def question
   if params[:id].present? && params[:question_id].present? 
     if(params[:id].to_i > 0)
       if check_user_surveys(params[:id])
          @survey = Survey.find(params[:id])
          @response = @survey.responses 
           if(params[:question_id].to_i > 0)            
             @survey_response = Response.find_by_survey_id_and_question_id(params[:id], params[:question_id])
              if @survey_response
               redirect_to previous_question_url(params[:id], params[:question_id])
              else
                @question = Question.find(params[:question_id])
                @sub_section = SubSection.find(@question.sub_section_id)
                @section = Section.find(@sub_section.section_id)
                @allSection = Section.all
                @response = Response.new
                @total_score = calculate_response_for_section(params[:id], @section.id)
                ########for pagination ############
                @question_all = Question.count
                if(params[:question_id].to_i < 6)
                @questions = Question.find(:all, :offset=> 0, :limit=>10) 
                elsif(params[:question_id].to_i > @question_all - 5)  
                @questions = Question.find(:all, :offset=> (@question_all - 10), :limit=>10)
                else
                @questions = Question.find(:all, :offset=> (params[:question_id].to_i - 5), :limit=>10)
                end 
                ######### end of pagination logic ########## 
              end                       
           end           
      else
       flash[:error] = "Something went wrong please select a survey"
       redirect_to continue_survey_url   
      end
    else
      flash[:error] = "Something went wrong please select a survey"
      redirect_to continue_survey_url  
    end  
   else
     flash[:error] = "Something went wrong please select a survey"
     redirect_to continue_survey_url 
   end 
end	


def create_response
	@response = Response.new
	@survey = Survey.find(params[:id])
	params[:response].merge!(:question_id => params[:question_id], :name =>params[:response][:answer_2])	
	@response = @survey.responses.create!(params[:response])	
  @question = Question.find(@response.question_id)
	@sub_section = SubSection.find(@question.sub_section_id)
	@section = Section.find(@sub_section.section_id)
	@total_score = calculate_response_for_section(params[:id], @section.id)
	redirect_to questions_url(@survey, params[:question_id].to_i+1)
end

#report of a particular survey
def report
  @survey = current_user.companies.first.surveys.find_all_by_id(params[:id])
  if @survey.present?
  @section_total = []
  @subsection_total = []
  @questions_score = []	
  @questions_score = []  
  @sections = Section.find(:all) 
  #score for each section and subsection
  @sections.each do |section|
     @section_total << calculate_response_for_section(params[:id], section.id)
     section.sub_sections.each do |sub_section|     
     @subsection_total << calculate_response_for_subsection(params[:id], sub_section.id)
    end
  end
  @final_score = @section_total[0]+@section_total[1]+@section_total[2]
  #get the individual response score
  @survey.responses.each do |response|
    @questions_score << get_individual_response_score(response.id, response.question_id)
  end  
  
  render :layout =>"report"
  else
   flash[:notice] = "No survey exists"
   redirect_to new_survey_path
  end
end	

def previous_question
	@survey = Survey.find(params[:id])
	@question = Question.find(params[:question_id])
	if @question    
    
    @survey_response = Response.find_by_survey_id_and_question_id(params[:id], params[:question_id])
    if @survey_response
       ########for pagination ############
        @question_all = Question.count
         if(params[:question_id].to_i < 6)
            @questions = Question.find(:all, :offset=> 0, :limit=>10) 
         elsif(params[:question_id].to_i > @question_all - 5)  
            @questions = Question.find(:all, :offset=> (@question_all - 10), :limit=>10)
         else
            @questions = Question.find(:all, :offset=> (params[:question_id].to_i - 5), :limit=>10)
         end 
    ######### end of pagination logic ##########      
      @sub_section = SubSection.find(@question.sub_section_id)
  	  @section = Section.find(@sub_section.section_id)
  	  @allSection = Section.all
  	  @response = Response.find_by_survey_id_and_question_id(params[:id], params[:question_id])	
  	  @total_score = calculate_response_for_section(params[:id], @section.id)
    else
     @response = @survey.responses.last 
     if @response
      redirect_to questions_url(@survey, @response.question_id.to_i+1) 
     else
      redirect_to questions_url(@survey, params[:question_id]) 
     end 
  end 
  else
    @response = @survey.responses.last 
    if @response
      redirect_to questions_url(@survey, @response.question_id.to_i+1) 
     else
      redirect_to questions_url(@survey, params[:question_id]) 
     end 
  end 
end

def update_response
   @survey = Survey.find(params[:id])
   @question = Question.find(params[:question_id])   	
   @response = Response.find_by_survey_id_and_question_id(params[:id], params[:question_id])
   params[:response].merge!(:name =>params[:response][:answer_2])
   @response.update_attributes(params[:response])
   @survey_response = Response.find_last_by_survey_id(params[:id])
   @sub_section = SubSection.find(@question.sub_section_id)
   @section = Section.find(@sub_section.section_id)
   @total_score = calculate_response_for_section(params[:id], @section.id)
   redirect_to questions_url(@survey, @survey.responses.last.question_id.to_i+1 )
end

#to download in pdf/xls format
def download_result
  require 'spreadsheet'
  @survey = Survey.find(params[:id])
  @section_total = []
  @subsection_total = []
  @questions_score = [] 
  @questions_score = []  
  @sections = Section.find(:all) 
  #score for each section and subsection
  @sections.each do |section|
     @section_total << calculate_response_for_section(params[:id], section.id)
     section.sub_sections.each do |sub_section|     
     @subsection_total << calculate_response_for_subsection(params[:id], sub_section.id)
    end
  end
  @final_score = @section_total[0]+@section_total[1]+@section_total[2]
  #get the individual response score
  @survey.responses.each do |response|
    @questions_score << get_individual_response_score(response.id, response.question_id)
  end  

  respond_to do |format|
      format.pdf {
        html = render_to_string(:layout => false , :action => "reports.html")
        kit = PDFKit.new(html)        
        send_data(kit.to_pdf, :filename => "survey.pdf", :type => 'application/pdf')
        return # to avoid double render call
      }

      format.xls {
        result = Spreadsheet::Workbook.new
        list = result.create_worksheet :name => "response" 
        list.row(0).concat %w{Section Subsection Questions QuestionPoints Score}
        @sections.each { |section|
           section.sub_sections.each { |subsection|
           subsection.questions.each { |question|
            list.row(question.id+1).push section.name, subsection.name, question.name, section.total_points,
            question.points, @questions_score[question.id]
          }           
         }
        }
        header_format = Spreadsheet::Format.new :color =>"green", :weight =>"bold"
        list.row(0).default_format = header_format
        #output to blob object
        blob = StringIO.new("")
        result.write blob
        #respond with blob object as a file
        send_data blob.string, :type =>:xls, :filename =>"result.xls"#; &quot;client_list.xls&quot;
      }
  end    
end


private
def check_company
  if !current_user.companies
     redirect_to new_company_url
  end
end	

def check_existing_surveys
  flag = false
  if current_user.companies.present?
     current_user.companies.each do |c|
       if c.surveys.present?
        flag = true      
       end  
     end 
  end
  return flag
end

def check_user_surveys(survey_id)
   @survey = Survey.find(survey_id)
   flag = false
   if current_user.companies.present?
     current_user.companies.each do |c|
       if c.surveys.present?
        c.surveys.each do |s| 
          if(s.id == @survey.id)
           flag = true      
          end
        end  
       end 
     end
   end
  return flag
end  

#total response for a section
def calculate_response_for_section(survey_id, section_id)
	questions = []	
	@section = Section.find(section_id)
	@section.sub_sections.each do |s|
     s.questions.each do |q|
       questions << q.id
     end
	end
  @survey = Survey.find(survey_id)
	@sur_responses = @survey.responses.find_all_by_question_id(questions)	
	calculate_response(@sur_responses)
end	

#total response for a subsection
def calculate_response_for_subsection(survey_id, sub_section_id)
  questions = []  
  @sub_section = SubSection.find(sub_section_id)
  @sub_section.questions.each do |q|
       questions << q.id
  end
  @survey = Survey.find(survey_id)
  @sur_responses = @survey.responses.find_all_by_question_id(questions) 
  calculate_response(@sur_responses)
end 

#calculate response 
def calculate_response(survey_response)  
  @total_score = 0 
  survey_response.each do |response|
    @score = 0
    @score = get_individual_response_score(response.id, response.question_id)    
    @total_score += @score 
  end
    return @total_score
 end

#individual score for each response
def get_individual_response_score(response_id, response_question_id)
  score = 0
  question = Question.find(response_question_id)
  response = Response.find(response_id)
  case question.points
        when 5 
          if response.answer_1 == "1"
            score = -1            
          end
           if response.answer_1 == "2"
            score = 0
          end 
           if response.answer_1 == "3"
            score = 1
          end
           if response.answer_1 == "4"
            score = 3
          end
           if response.answer_1 == "5"
            score = 5
          end         

       when 10 
          if response.answer_1 == "1"
            score = -2
          end
           if response.answer_1 == "2"
            score = 0
          end 
           if response.answer_1 == "3"
            score = 2
          end
           if response.answer_1 == "4"
            score = 6
          end
           if response.answer_1 == "5"
            score = 10
          end          

        when 20 
          if response.answer_1 == "1"
            score = -4
          end
           if response.answer_1 == "2"
            score = 0
          end 
           if response.answer_1 == "3"
            score = 4
          end
           if response.answer_1 == "4"
            score = 12
          end
           if response.answer_1 == "5"
            score = 20
          end
        end        
       return score
end

 
end
