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
                @total_score = calculate_response_for_section(params[:id], @section.id)
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
	    @total_score = calculate_response_for_section(@survey.id, @section.id)
	    redirect_to questions_url(@survey, params[:response][:question_id].to_i+1)
   else    
     redirect_to confirm_survey_url(@survey.id)
   end
  end
end

#report of a particular survey
def report
  require 'rubygems'
 require 'google_chart'
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
                @total_score = calculate_response_for_section(params[:id], @section.id)
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
      @total_score = calculate_response_for_section(@survey.id, @section.id)      
      redirect_to questions_url(@survey, @question.id)
   else          
     redirect_to confirm_survey_url(@survey.id)
   end
  end
end

def confirm_survey
  @questions=[]
  @section =[]
  @survey = Survey.find_by_id(params[:id])   
  @questions  = Section.find(:all,
                           :select => "count(*) as question_attempted",
                           :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id left outer join responses on responses.question_id = questions.id 
                                      where responses.survey_id=#{params[:id]}",
                           :group => "sections.id")
  @sections = Section.all
  @section1 = @questions[0].question_attempted
  @section2 = @questions[1].question_attempted
  @section3 = @questions[2].question_attempted
  @final_score = @section1.to_i + @section2.to_i + @section3.to_i
 end
 

def close_survey
   @survey = Survey.find_by_id(params[:id])
   if @survey.update_attribute(:is_active, false)
     flash[:success] = "Thank you for taking up the survey"
     redirect_to reports_url(params[:id])
   else
     flash[:success] = "Thank you for taking up the survey"
     redirect_to confirm_survey_url(@survey.id)
   end 
end

def report_detailed
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
 end 
 id = params[:id]
@responses = Response.find(:all, 
  :select => "questions.name,responses.answer_1, questions.points, sections.name as section_name, sub_sections.name as sub_sect_name", 
  :joins => "right outer join questions on responses.question_id = questions.id 
             left outer join sub_sections on questions.sub_section_id = sub_sections.id 
             left outer join sections on sections.id = sub_sections.section_id   
             and responses.survey_id =#{id}"  
   )

end  

def compare
 require 'rubygems'
require 'google_chart'

 @question_ids = []
   @questions = Question.find(:all,
    :select => "questions.id, responses.question_id as response_quest_id",
    :joins => "left outer join responses on responses.question_id = questions.id and responses.survey_id=#{params[:id]}")
  Question.all.each do |qst|
   @question_ids << "#{qst.id}"
   end   
  @response_all = []
  @questions.each do |q|
  @response = Response.find_by_question_id_and_survey_id(q.id,params[:id])
    if @response  
     @response_all << get_individual_response_score(@response.id, @response.question_id)    
    end        
  end
  #Average response for all survey
  @survey = Survey.find(params[:id])
  @company = Company.find(@survey.company_id)
  @industry  = Industry.find(@company.industry_id)
  @companies = Company.find(:all, 
   :select => "industries.id, companies.id",
   :joins =>"right outer join industries on companies.industry_id = industries.id    
   where industries.id = #{@company.industry_id} and companies.id !=#{@survey.company_id}"
   )

  #get all the surveys for the industry 

  #@responses_kk =  Responses.find(:all, 
 #:select =>
  #  ) 
  # @responses_average = []
  # response_total = 0
  # @companies.each do |cmp|
  #   cmp.surveys.each do |survey|
  #     survey.responses.each do |responses|        
  #       response_total += responses.answer_1.to_i 
  #     end
  #     @responses_average << response_total 
  #   end  
  # end  
  
  GoogleChart::LineChart.new("700x300", "Overall", false) do |lc|
  lc.data "Line green", ['2','3'], '00ff00'
  lc.data "Line red", @responses_average, 'ff0000'
  lc.axis :y, :range =>[0,5], :font_size =>10, :alignment =>:center
  lc.axis :x, :range =>@question_ids, :font_size =>10, :alignment =>:center
  lc.show_legend = false
  lc.shape_marker :circle, :color => '0000ff', :data_set_index => 0, :data_point_index => -1, :pixel_size => 10
  @line_graph =  lc.to_url
  end

end  

def compare_system
  require 'rubygems'
 require 'google_chart'

  @questions = Question.find(:all,
   :select => "questions.id, responses.question_id as response_quest_id",
   :joins => "left outer join responses on responses.question_id = questions.id  
   left outer join sub_sections on questions.sub_section_id = sub_sections.id left outer 
   join sections on sub_sections.section_id = sections.id where responses.survey_id=#{params[:id]} and sections.id = 1")
    @response_all = []
    @questions.each do |q|
    @response = Response.find_by_question_id(q.id)
    if @response  
     @response_all << get_individual_response_score(@response.id, @response.question_id)
    end        
  end  
  @lcp = GoogleChart::LineChart.new("400x200", "My Results", false)
  @lcp.data "Line green", [3,5,1,9,0,2], '00ff00'
  @lcp.data "Line red", [2,4,0,6,9,3], 'ff0000'
  @lcp.axis :y, :range => [0,10], :font_size =>10, :alignment=>"center"
  @lcp.show_legend = false
  @lcp.shape_marker :circle, :color =>'0000ff', :data_set_index =>0, :data_point_index =>-1, :pixel_size =>10
  @line_graph_system =  @lcp.to_url
  
  @responses = Response.find(:all, 
  :select => "questions.name,responses.answer_1, questions.points, sections.name as section_name, sub_sections.name as sub_sect_name", 
  :joins => "right outer join questions on responses.question_id = questions.id 
             left outer join sub_sections on questions.sub_section_id = sub_sections.id 
             left outer join sections on sections.id = sub_sections.section_id   
             and responses.survey_id =#{params[:id]}"  
   )
end  

def compare_strategy
  require 'rubygems'
 require 'google_chart'

  @questions = Question.find(:all,
   :select => "questions.id, responses.question_id as response_quest_id",
   :joins => "left outer join responses on responses.question_id = questions.id  
   left outer join sub_sections on questions.sub_section_id = sub_sections.id left outer 
   join sections on sub_sections.section_id = sections.id where responses.survey_id=#{params[:id]} and sections.id = 2")
    @response_all = []
    @questions.each do |q|
    @response = Response.find_by_question_id(q.id)
    if @response  
    @response_all << get_individual_response_score(@response.id, @response.question_id)
    else 
    @response_all << 0
    end        
  end
  @lc = GoogleChart::LineChart.new("400x200", "My Results", false)
  @lc.data "Line green", [3,5,1,9,0,2], '00ff00'
  @lc.data "Line red", [2,4,0,6,9,3], 'ff0000'
  @lc.axis :y, :range => [0,10], :font_size =>10, :alignment=>"center"
  @lc.show_legend = false
  @lc.shape_marker :circle, :color =>'0000ff', :data_set_index =>0, :data_point_index =>-1, :pixel_size =>10
  @line_graph_strategy = @lc.to_url
  
  @responses = Response.find(:all, 
  :select => "questions.name,responses.answer_1, questions.points, sections.name as section_name, sub_sections.name as sub_sect_name", 
  :joins => "right outer join questions on responses.question_id = questions.id 
             left outer join sub_sections on questions.sub_section_id = sub_sections.id 
             left outer join sections on sections.id = sub_sections.section_id   
             and responses.survey_id =#{params[:id]}"  
   )
end  

def compare_programs
  require 'rubygems'
  require 'google_chart'

  @questions = Question.find(:all,
   :select => "questions.id, responses.question_id as response_quest_id",
   :joins => "left outer join responses on responses.question_id = questions.id  
   left outer join sub_sections on questions.sub_section_id = sub_sections.id left outer 
   join sections on sub_sections.section_id = sections.id where responses.survey_id=#{params[:id]} and sections.id = 3")
    @response_all = []
    @questions.each do |q|
    @response = Response.find_by_question_id(q.id)
    if @response  
    @response_all << get_individual_response_score(@response.id, @response.question_id)
    else 
    @response_all << 0
    end        
  end
 @lc = GoogleChart::LineChart.new("400x200", "My Results", false)
@lc.data "Line green", [3,5,1,9,0,2], '00ff00'
@lc.data "Line red", [2,4,0,6,9,3], 'ff0000'
@lc.axis :y, :range => [0,10], :font_size =>10, :alignment=>"center"
@lc.show_legend = false
@lc.shape_marker :circle, :color =>'0000ff', :data_set_index =>0, :data_point_index =>-1, :pixel_size =>10
 @line_graph_program = @lc.to_url
  
   @responses = Response.find(:all, 
  :select => "questions.name,responses.answer_1, questions.points, sections.name as section_name, sub_sections.name as sub_sect_name", 
  :joins => "right outer join questions on responses.question_id = questions.id 
             left outer join sub_sections on questions.sub_section_id = sub_sections.id 
             left outer join sections on sections.id = sub_sections.section_id   
             and responses.survey_id =#{params[:id]}"  
   )
end  

#to download in pdf/xls format
def download_result

  logger.debug "&&&&&&& download_result start"
  require 'rubygems'
 require 'google_chart'
  #require 'spreadsheet'

  #  GoogleChart::LineChart.new("400x300", "Overall", false) do |lc|
  # lc.data "Line green", [1,2,3,4,5], '00ff00'
  # lc.axis :y, :range =>['0','5','10','15','20'], :font_size =>10, :alignment =>:center
  # lc.axis :x, :range =>[2,4,6,8.10], :font_size =>10, :alignment =>:center
  # lc.show_legend = false
  # lc.shape_marker :circle, :color => '0000ff', :data_set_index => 0, :data_point_index => -1, :pixel_size => 4
  # @line_graph =  lc.to_url
  # end

  @lc = GoogleChart::LineChart.new("400x200", "My Results", false)
@lc.data "Line green", [3,5,1,9,0,2], '00ff00'
@lc.data "Line red", [2,4,0,6,9,3], 'ff0000'
@lc.axis :y, :range => [0,10], :font_size =>10, :alignment=>"center"
@lc.show_legend = false
@lc.shape_marker :circle, :color =>'0000ff', :data_set_index =>0, :data_point_index =>-1, :pixel_size =>10
@line_graph = @lc.to_url
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
      format.html{}
      format.pdf {
       html = render_to_string(:layout => false , :action => "reports.html")
       kit = PDFKit.new(html)
       #kit.stylesheets << File.join( RAILS_ROOT, "assets", "stylesheets", "application.css" )
       send_data(kit.to_pdf, :filename => "survey.pdf", :type => "application/pdf")
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

def get_question_ids(section)
  section_questions =[]
  section = Section.find(section)
  section.sub_sections.each do |subsect|
  subsect.questions.each do |q|
       section_questions << q.id
   end 
 end
   return section_questions
end

def get_response_score_for(survey_id)
  @total = 0
 @survey = Survey.find(survey_id) 
 @survey.responses.each do |response|
   @total += get_individual_response_score(response.id, response.question_id)
 end
 return @total
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
