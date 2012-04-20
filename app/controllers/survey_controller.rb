class SurveyController < ApplicationController

before_filter :authenticate_user!, :check_company #check current_user & company
 
layout "application"

def index
  redirect_to continue_survey_url
end  
#new survey
def new
  @active_survey = []
  @previous_surveys = []
  @response = []
  if current_user.companies.present?#if no company details is provided
        if check_existing_surveys #check if there exists previous surveys
            current_user.companies.each do |cmpany|
            cmpany.surveys.each do |survey|    
                if survey.is_active == true                    
                  @active_survey << survey.id
                end  
            end              
            end
            flash[:success] = "Welcome back #{current_user.username}, please select a survey to continue"
            redirect_to continue_survey_url               
        else
          #list all the previous completed surveys & start a new survey
          current_user.companies.each do |cmpany|
            cmpany.surveys.each do |survey|    
            if survey.is_active == false                    
              @previous_surveys << survey.id
              @response << get_response_score_for(survey.id)
            end  
          end
          end       
          @survey = Survey.new
          @survey_date = Time.now.strftime('%B, %Y')
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
     @survey_name = @survey.created_at.strftime('%B,%Y')
	   flash[:success] = "Survey #{@survey_name} created successfully"
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
                 @survey_name = @survey.created_at.strftime('%B,%Y')
                 flash[:success] = "Continue Survey #{@survey_name}" 
                 redirect_to questions_url(@survey, res[0]) 
              else
               @survey_name = @survey.created_at.strftime('%B,%Y') 
               flash[:success] = "Start Survey #{@survey_name}" 
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
  @sections= Section.all  
  @total_questions = @sections[0].question_count+@sections[1].question_count+@sections[2].question_count     
end  

#question for the survey	
def question
   if params[:id].present? && params[:question_id].present? 
     if((Survey.check_numericality(params[:id])) && (check_survey(params[:id])))
       if check_user_surveys(params[:id])
          @survey = Survey.find(params[:id])
          @response = @survey.responses 
           if((Survey.check_numericality(params[:question_id])) && (check_question(params[:question_id])))          
             
             @survey_response = Response.find_by_survey_id_and_question_id(params[:id], params[:question_id])
              if @survey_response
               redirect_to previous_question_url(params[:id], params[:question_id])
              else
                @question = Question.find(params[:question_id])
                @sub_section = SubSection.find(@question.sub_section_id)
                @section = Section.find(@sub_section.section_id)
                @allSection = Section.all
                @response = Response.new
                @total_score = Survey.calculate_response_for_section(params[:id], @section.id)
                ########for pagination ############
               
                @question_all = Question.count
                if(params[:question_id].to_i < 6)
                @questions = Question.find(:all,
                       :select => "questions.id, responses.question_id as response_quest_id",
                       :joins => "left outer join responses on responses.question_id = questions.id and responses.survey_id=#{params[:id]}", 
                       :offset=> 0, :limit=>10 )

                elsif(params[:question_id].to_i > @question_all - 5)  
                @questions = Question.find(:all,
                       :select => "questions.id, responses.question_id as response_quest_id",
                       :joins => "left outer join responses on responses.question_id = questions.id and responses.survey_id=#{params[:id]}", 
                       
                       :offset=> (@question_all - 10), :limit=>10 )
                else
                @questions = Question.find(:all,
                       :select => "questions.id, responses.question_id as response_quest_id",
                       :joins => "left outer join responses on responses.question_id = questions.id and responses.survey_id=#{params[:id]}", 
                       
                       :offset=> (params[:question_id].to_i - 5), :limit=>10)
                end 
                ######### end of pagination logic ########## 
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
   else
     flash[:error] = "Something went wrong please select a survey"
     redirect_to continue_survey_url 
   end 
end	


def create_response	
  if params[:response].blank?  
    flash[:error] = "Could not save response for some reason please try again"
    redirect_to continue_survey_url
  else
   @response = Response.new 
	 @survey = Survey.find(params[:response][:survey_id])
	 params[:response].merge!(:name =>params[:response][:answer_2])	
	 @response = @survey.responses.create!(params[:response])	
   @question = Question.find(@response.question_id)
   if @question.id < Question.last.id
      @sub_section = SubSection.find(@question.sub_section_id)
	    @section = Section.find(@sub_section.section_id)
	    @total_score = Survey.calculate_response_for_section(@survey.id, @section.id)
	    redirect_to questions_url(@survey, params[:response][:question_id].to_i+1)
   else    
     redirect_to confirm_survey_url(@survey.id)
   end
  end
end

#report of a particular survey
def report  
  @survey = current_user.companies.first.surveys.find_all_by_id(params[:id])
  if @survey.present?
  @section_total = []
  @subsection_total = []
  @questions_score = []	
  @questions_score = []  
  @allSection = Section.find(:all) 
  #score for each section and subsection
  @allSection.each do |section|
     @section_total << Survey.calculate_response_for_section(params[:id], section.id)
     section.sub_sections.each do |sub_section|     
     @subsection_total << calculate_response_for_subsection(params[:id], sub_section.id)
    end
  end
  @final_score = @section_total[0]+@section_total[1]+@section_total[2]
  #get the individual response score
  @survey.responses.each do |response|
    @questions_score << Survey.get_individual_response_score(response.id, response.question_id)
  end  
  
  render :layout =>"report"
  else
   flash[:notice] = "No such survey exists"
   redirect_to new_survey_path
  end
end	

def previous_question
  if params[:id].present? && params[:question_id].present? 
     if((Survey.check_numericality(params[:id])) && (check_survey(params[:id])))
       if check_user_surveys(params[:id])
          @survey = Survey.find(params[:id])
          @response = @survey.responses 
           if((Survey.check_numericality(params[:question_id])) && (check_question(params[:question_id])))          
             @survey_response = Response.find_by_survey_id_and_question_id(params[:id], params[:question_id])
              if @survey_response

                @question = Question.find(params[:question_id])
                @sub_section = SubSection.find(@question.sub_section_id)
                @section = Section.find(@sub_section.section_id)
                @allSection = Section.all
                @response = Response.find_by_survey_id_and_question_id(params[:id], params[:question_id])
                @total_score = Survey.calculate_response_for_section(params[:id], @section.id)
                ########for pagination ############
                @question_all = Question.count
                if(params[:question_id].to_i < 6)
                @questions = Question.find(:all,
                       :select => "questions.id, responses.question_id as response_quest_id",
                       :joins => "left outer join responses on responses.question_id = questions.id and responses.survey_id=#{params[:id]}", 
                       :offset=> 0, :limit=>10 )

                elsif(params[:question_id].to_i > @question_all - 5)  
                @questions = Question.find(:all,
                       :select => "questions.id, responses.question_id as response_quest_id",
                       :joins => "left outer join responses on responses.question_id = questions.id and responses.survey_id=#{params[:id]}", 
                       
                       :offset=> (@question_all - 10), :limit=>10 )
                else
                @questions = Question.find(:all,
                       :select => "questions.id, responses.question_id as response_quest_id",
                       :joins => "left outer join responses on responses.question_id = questions.id and responses.survey_id=#{params[:id]}", 
                       
                       :offset=> (params[:question_id].to_i - 5), :limit=>10)
                end 
                ######### end of pagination logic ##########               
              else
                redirect_to questions_url(@survey, params[:question_id])
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
   else
     flash[:error] = "Something went wrong please select a survey"
     redirect_to continue_survey_url 
   end 
	
end

def update_response  
  if params[:response].blank?  
    flash[:error] = "Could not save response for some reason please try again"
    redirect_to continue_survey_url
  else
   @survey = Survey.find(params[:response][:survey_id])
   @response = Response.find_by_survey_id_and_question_id(params[:response][:survey_id], params[:response][:question_id])
   params[:response].merge!(:name =>params[:response][:answer_2])
   @response.update_attributes(params[:response])
   @questions = Question.find(@response.question_id)
   if @questions.id.to_i+1 < Question.last.id
      @question = Question.find(@response.question_id.to_i + 1)
      @sub_section = SubSection.find(@question.sub_section_id)
      @section = Section.find(@sub_section.section_id)
      @total_score = Survey.calculate_response_for_section(@survey.id, @section.id)      
      redirect_to questions_url(@survey, @question.id)
   else          
     redirect_to confirm_survey_url(@survey.id)
   end
  end
end

def confirm_survey
  @questions=[]
  @final_score = 0
  @total_question_count = 0
  @survey = Survey.find_by_id(params[:id])   
  @questions  = Section.find(:all,
                           :select => "count(responses.question_id) as question_attempted",
                           :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id left outer join responses on (responses.question_id = questions.id and responses.survey_id=#{params[:id]})",
                           :group => "sections.id", :order => "sections.id")
  @allSection = Section.all
  @allSection.each_with_index do |section,i|
    @final_score += @questions[i].question_attempted.to_i
    @total_question_count += section.question_count
  end
 end
 

def close_survey
   @survey = Survey.find_by_id(params[:id])
   if @survey.update_attribute(:is_active, false)
     flash[:success] = "Thank you for taking up the survey"
     redirect_to reports_url(params[:id])
   else
     flash[:success] = "Sorry could not close the survey"
     redirect_to confirm_survey_url(@survey.id)
   end 
end


def compare   
  @allSection = Section.all 
  @survey = Survey.find(params[:id])
  @line_graph = Survey.get_overall_graph(@survey.id)
end 

def compare_strategy
  @allSection = Section.all 
  @survey = Survey.find(params[:id])
  @line_graph_strategy = Survey.get_section_graph(@allSection[0].id, @survey.id)
  @responses = Survey.get_result(@allSection[0].id, @survey.id)
end  


def compare_system
  @allSection = Section.all 
  @survey = Survey.find(params[:id])
  @line_graph_system = Survey.get_section_graph(@allSection[1].id, @survey.id)
  @responses = Survey.get_result(@allSection[1].id, @survey.id)
end  


def compare_programs
  @allSection = Section.all 
  @survey = Survey.find(params[:id])
  @line_graph_programs = Survey.get_section_graph(@allSection[2].id, @survey.id)
  @responses = Survey.get_result(@allSection[2].id, @survey.id)
end  

  def reports
   @sections = Section.find(:all) 
  @survey = Survey.find(params[:id])
  end   

#to download in pdf/xls format
def download_result
  require 'rubygems'
  require 'google_chart'
  require 'spreadsheet'  
  
  @sections = Section.find(:all) 
  @survey = Survey.find(params[:id])
  respond_to do |format|
      format.html{}
       format.pdf {
        html = render_to_string(:layout => false , :action => "reports.html")
        kit = PDFKit.new(html)    
        kit.stylesheets << Rails.root.join("app/assets/stylesheets/jquery.dataTables.css") 
        kit.stylesheets << Rails.root.join("app/assets/stylesheets/application.css")   
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
         c.surveys.each do |survey|
         if survey.is_active == true       
          flag = true      
         end
        end  
       end  
     end 
  end
  return flag
end

def check_survey(survey_id)
  @survey = Survey.find_by_id(survey_id)
  if @survey.present?
    return true
  else
    return false
  end    
end

def check_question(question_id)  
  @question = Question.find_by_id(question_id)
  if @question.present?
    return true
  else
    return false
  end    
end  

def check_user_surveys(survey_id)
   @survey = Survey.find_by_id(survey_id)
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


#total response for a subsection
def calculate_response_for_subsection(survey_id, sub_section_id)
  questions = []  
  @sub_section = SubSection.find(sub_section_id)
  @sub_section.questions.each do |q|
       questions << q.id
  end
  @survey = Survey.find(survey_id)
  @sur_responses = @survey.responses.find_all_by_question_id(questions) 
  Survey.calculate_response(@sur_responses)
end 
 
end
