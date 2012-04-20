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
  @sections = Section.find(:all) 
  #score for each section and subsection
  @sections.each do |section|
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
  @section =[]
  @survey = Survey.find_by_id(params[:id])   
  @questions  = Section.find(:all,
                           :select => "count(responses.question_id) as question_attempted",
                           :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id left outer join responses on (responses.question_id = questions.id and responses.survey_id=#{params[:id]})",
                           :group => "sections.id", :order => "sections.id")
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
     flash[:success] = "Sorry could not close the survey"
     redirect_to confirm_survey_url(@survey.id)
   end 
end


def compare
 require 'rubygems'
 require 'google_chart'
  @sections = Section.all  
  @survey = Survey.find(params[:id])
  @question_count =Question.all.count
  @response = Response.find(:all,
  :select =>"responses.answer_1, questions.id as questions_id",
  :joins=>"right outer join questions on questions.id=responses.question_id 
           where responses.survey_id=#{@survey.id}"
    )
  @response_all = []
  @sections = Section.all
  #Average response for all survey
  @survey = Survey.find(params[:id])
  @company = Company.find(@survey.company_id)
  @industry  = Industry.find(@company.industry_id)
  @companies = Company.find(:all,
   :select => "industries.id, companies.id",
   :joins =>"right outer join industries on companies.industry_id = industries.id   
   where industries.id = '1' and companies.id !=#{@survey.company_id}"
   )
   if @companies.present?
  @company_ids=@companies.map(&:id)
  @response_all = Response.find(:all,
     :select=>"sum(responses.answer_1), questions.id, surveys.id",
     :joins =>"right outer join questions on questions.id=responses.question_id
              left outer join surveys on  surveys.company_id in (3,11,13)
              where responses.survey_id!=#{@survey.id}",
     :group=>"surveys.id, responses.answer_1, questions.id"    
     )
  else
    @response_all = Response.find(:all,
     :select=>"count(*), responses.answer_1, questions.id",
     :joins =>"right outer join questions on questions.id=responses.question_id
              left outer join surveys on responses.survey_id = surveys.id where 
              responses.survey_id!=#{@survey.id}",
     :group=>"questions.id, responses.answer_1"    
     )
  end  
  
  GoogleChart::LineChart.new("900x330", "Overall", false) do |line_graph|
    line_graph.data "Your Response", @response.map(&:answer_1).collect{|i| i.to_i}, '00ff00'
    line_graph.data "Overall Response", @response_all.map(&:answer_1).collect{|i| i.to_i}, 'ff0000'
    line_graph.axis :y, :range =>[0,5], :labels =>[0,1,2,3,4,5], :font_size =>10, :alignment =>:center
    line_graph.axis :x, :range =>[0,@question_count], :font_size =>10, :alignment =>:center
    line_graph.show_legend = true
    line_graph.shape_marker :circle, :color => '0000ff', :data_set_index => 0, :data_point_index => -1, :pixel_size => 5
    #line_graph.fill :background, :gradient, :angle=>0, :color=>[['FFFFFF', 1], ['76A4FA', 0]]
    #line_graph.fill :chart, :gradient, :angle=>0, :color=>[['76A4FB', 1], ['FFFFFF', 0]]
    line_graph.grid :x_step => 100.0/10, :y_step=>100.0/10, :length_segment =>1, :length_blank => 0
    @line_graph =  line_graph.to_url
  end
end 

def compare_system
 require 'rubygems'
 require 'google_chart'
 
 @sections = Section.all  
 @survey = Survey.find(params[:id])
  @question_count = Question.find(:all,
    :select=>"count(*) as system_count",
    :joins=>"right outer join sub_sections on questions.sub_section_id = sub_sections.id 
             inner join sections on sections.id = sub_sections.section_id where sections.id =2")
  @response = Response.find(:all,
  :select =>"responses.answer_1, questions.id",
  :joins=>"right outer join questions on questions.id=responses.question_id 
           left outer join sub_sections on questions.sub_section_id = sub_sections.id 
           inner join sections on sections.id = sub_sections.section_id
           where responses.survey_id=#{@survey.id} and sections.id = 2",
   :order => "questions.id ASC")
  @response_all = []
  
  #Average response for all survey
  @survey = Survey.find(params[:id])
  @company = Company.find(@survey.company_id)
  
  @companies = Company.find(:all,
   :select => "industries.id, companies.id",
   :joins =>"right outer join industries on companies.industry_id = industries.id   
   where industries.id = #{@company.industry_id} and companies.id !=#{@survey.company_id}"
   )
  if @companies.present?
  @company_ids=@companies.map(&:id)
  @response_all = Response.find(:all,
     :select=>"count(*),responses.answer_1, questions.id, surveys.id",
     :joins =>"right outer join questions on questions.id=responses.question_id
              left outer join surveys on  surveys.company_id IN (3,11,13) 
              left outer join sub_sections on questions.sub_section_id = sub_sections.id 
              inner join sections on sections.id = sub_sections.section_id
              where responses.survey_id!=#{@survey.id} and sections.id = 2",
     :group=>"surveys.id, responses.answer_1, questions.id"    
     )
  else
    @response_all = Response.find(:all,
     :select=>"count(*), responses.answer_1, questions.id",
     :joins =>"right outer join questions on questions.id=responses.question_id
              left outer join surveys on responses.survey_id = surveys.id 
              left outer join sub_sections on questions.sub_section_id = sub_sections.id 
              inner join sections on sections.id = sub_sections.section_id
              where responses.survey_id!=#{@survey.id} and sections.id = 2",
     :group=>"questions.id, responses.answer_1"    
     )
  end  
  
  GoogleChart::LineChart.new("900x330", "Systems", false) do |line_gph|
    line_gph.data "Your Response", @response.map(&:answer_1).collect{|i| i.to_i}, '00ff00'
    line_gph.data "Overall Response", @response_all.map(&:answer_1).collect{|i| i.to_i}, 'ff0000'
    line_gph.axis :y, :range =>[0,5], :labels =>[0,1,2,3,4,5], :font_size =>10, :alignment =>:center
    line_gph.axis :x, :range =>[0,@question_count.first.system_count], :font_size =>10, :alignment =>:center
    line_gph.show_legend = true
    line_gph.shape_marker :circle, :color => '0000ff', :data_set_index => 0, :data_point_index => -1, :pixel_size => 4
    #line_gph.fill :background, :gradient, :angle=>0, :color=>[['FFFFFF', 1], ['76A4FA', 0]]
    line_gph.grid :x_step => 100.0/10, :y_step=>100.0/10, :length_segment =>1, :length_blank => 0
    @line_graph_system =  line_gph.to_url
  end
  @responses = Response.find(:all, 
  :select => "questions.id as questions_id, sections.id as section_id, responses.id as response_id, questions.name,responses.answer_1 as score, responses.answer_2 as in_plan, responses.answer_3, questions.points, sections.name as section_name, sub_sections.name as sub_sect_name, avg(responses.answer_1) as avg_score, responses.survey_id as survey_id", 
  :joins => "right outer join questions on (responses.question_id = questions.id and responses.survey_id =#{params[:id]} )
             left outer join sub_sections on questions.sub_section_id = sub_sections.id 
             inner join sections on sections.id = sub_sections.section_id   
             where sections.id=2",
  :group => "questions.id,responses.id, sections.id, responses.survey_id, questions.name, responses.answer_1, responses.answer_2, responses.answer_3, sections.name, sub_sections.name, questions.points"                         
   )
end  

def compare_strategy
 require 'rubygems'
 require 'google_chart'
  @sections = Section.all 
  @survey = Survey.find(params[:id])
  @question_count = Question.find(:all,
    :select=>"count(*) as strategy_count",
    :joins=>"right outer join sub_sections on questions.sub_section_id = sub_sections.id
             inner join sections on sections.id = sub_sections.section_id where sections.id =1")
  @response = Response.find(:all,
  :select =>"responses.answer_1, questions.id",
  :joins=>"right outer join questions on questions.id=responses.question_id 
           left outer join sub_sections on questions.sub_section_id = sub_sections.id 
           inner join sections on sections.id = sub_sections.section_id
           where responses.survey_id=#{@survey.id} and sections.id = 1",
   :order => "questions.id ASC")
  @response_all = []
  
  #Average response for all survey
  @survey = Survey.find(params[:id])
  @company = Company.find(@survey.company_id)
  
  @companies = Company.find(:all,
   :select => "companies.id",
   :joins =>"right outer join industries on companies.industry_id = industries.id   
   where industries.id = #{@company.industry_id} and companies.id !=#{@survey.company_id}"
   )

  if @companies.present?
    @company_ids = @companies.map(&:id)
    @response_all = Response.find(:all,
     :select=>"count(*),responses.answer_1, questions.id, surveys.id",
     :joins =>"right outer join questions on questions.id=responses.question_id
              left outer join surveys on  surveys.company_id IN (3,11,13)  
              left outer join sub_sections on questions.sub_section_id = sub_sections.id 
              inner join sections on sections.id = sub_sections.section_id
              where responses.survey_id!=#{@survey.id} and sections.id = 1",
     :group=>"surveys.id, responses.answer_1, questions.id"    
     )
  else
    @response_all = Response.find(:all,
     :select=>"count(*), responses.answer_1, questions.id",
     :joins =>"right outer join questions on questions.id=responses.question_id
              left outer join surveys on responses.survey_id = surveys.id 
              left outer join sub_sections on questions.sub_section_id = sub_sections.id 
              inner join sections on sections.id = sub_sections.section_id
              where responses.survey_id!=#{@survey.id} and sections.id = 1",
     :group=>"questions.id, responses.answer_1"    
     )
  end  
  
  GoogleChart::LineChart.new("900x330", "Strategy", false) do |line_gph|
    line_gph.data "Your Response", @response.map(&:answer_1).collect{|i| i.to_i}, '00ff00'
    line_gph.data "Overall Response", @response_all.map(&:answer_1).collect{|i| i.to_i}, 'ff0000'
    line_gph.axis :y, :range =>[0,5], :labels =>[0,1,2,3,4,5], :font_size =>10, :alignment =>:center
    line_gph.axis :x, :range =>[0,@question_count.first.strategy_count], :font_size =>10, :alignment =>:center
    line_gph.show_legend = true
    line_gph.shape_marker :circle, :color => '0000ff', :data_set_index => 0, :data_point_index => -1, :pixel_size => 4
    line_gph.grid :x_step => 100.0/10, :y_step=>100.0/10, :length_segment =>1, :length_blank => 0
    @line_graph_strategy =  line_gph.to_url
  end
  @responses = Response.find(:all, 
  :select => "questions.id as questions_id,responses.id as response_id, sections.id as section_id, questions.name,responses.answer_1 as score, responses.answer_2 as in_plan, responses.answer_3, questions.points, sections.name as section_name, sub_sections.name as sub_sect_name, avg(responses.answer_1) as avg_score, responses.survey_id as survey_id ", 
  :joins => "right outer join questions on (responses.question_id = questions.id and responses.survey_id =#{params[:id]})
             left outer join sub_sections on questions.sub_section_id = sub_sections.id 
             left outer join sections on sections.id = sub_sections.section_id   
             where sections.id=1",
   :group => "questions.id, responses.id, sections.id, responses.survey_id, questions.name, responses.answer_1, responses.answer_2, responses.answer_3, sections.name, sub_sections.name, questions.points"            
   ) 
end  

def compare_programs
 require 'rubygems'
 require 'google_chart'
 @sections = Section.all  
 @survey = Survey.find(params[:id])
  @question_count = Question.find(:all,
    :select=>"count(*) as program_count",
    :joins=>"right outer join sub_sections on questions.sub_section_id = sub_sections.id 
             inner join sections on sections.id = sub_sections.section_id where sections.id =3")
  @response = Response.find(:all,
  :select =>"responses.answer_1, questions.id",
  :joins=>"right outer join questions on questions.id=responses.question_id 
           left outer join sub_sections on questions.sub_section_id = sub_sections.id 
           inner join sections on sections.id = sub_sections.section_id
           where responses.survey_id=#{@survey.id} and sections.id = 3",
   :order => "questions.id ASC")
  @response_all = []
  
  #Average response for all survey
  @survey = Survey.find(params[:id])
  @company = Company.find(@survey.company_id)
  @industry  = Industry.find(@company.industry_id)
  @companies = Company.find(:all,
   :select => "industries.id, companies.id",
   :joins =>"right outer join industries on companies.industry_id = industries.id   
   where industries.id = #{@company.industry_id} and companies.id !=#{@survey.company_id}"
   )
  if @companies.present?
  @company_ids = @companies.map(&:id)  
  @response_all = Response.find(:all,
     :select=>"responses.answer_1, questions.id, surveys.id",
     :joins =>"right outer join questions on questions.id=responses.question_id
              left outer join surveys on surveys.company_id in (3,11,13) 
              left outer join sub_sections on questions.sub_section_id = sub_sections.id 
              inner join sections on sections.id = sub_sections.section_id
              where responses.survey_id!=#{@survey.id} and sections.id = 3",
     :group=>"surveys.id,responses.answer_1, questions.id"    
     )
  else
    @response_all = Response.find(:all,
     :select=>"count(*), responses.answer_1, questions.id",
     :joins =>"right outer join questions on questions.id=responses.question_id
              left outer join surveys on responses.survey_id = surveys.id 
              left outer join sub_sections on questions.sub_section_id = sub_sections.id 
              inner join sections on sections.id = sub_sections.section_id
              where responses.survey_id!=#{@survey.id} and sections.id = 3",
     :group=>"questions.id, responses.answer_1"    
     )
  end  
  
  GoogleChart::LineChart.new("900x330", "Programs", false) do |line_gph|
    line_gph.data "Your Response", @response.map(&:answer_1).collect{|i| i.to_i}, '00ff00'
    line_gph.data "Overall Response", @response_all.map(&:answer_1).collect{|i| i.to_i}, 'ff0000'
    line_gph.axis :y, :range =>[0,5], :labels =>[0,1,2,3,4,5], :font_size =>10, :alignment =>:center
    line_gph.axis :x, :range =>[0,@question_count.first.program_count], :font_size =>10, :alignment =>:center
    line_gph.show_legend = true
    line_gph.shape_marker :circle, :color => '0000ff', :data_set_index => 0, :data_point_index => -1, :pixel_size => 4
    line_gph.grid :x_step => 100.0/10, :y_step=>100.0/10, :length_segment =>1, :length_blank => 0
    @line_graph_programs =  line_gph.to_url
  end
  @responses = Response.find(:all, 
  :select => "questions.id as questions_id, sections.id as section_id, responses.id as response_id, questions.name,responses.answer_1 as score, responses.answer_2 as in_plan, responses.answer_3, questions.points, sections.name as section_name, sub_sections.name as sub_sect_name, avg(responses.answer_1) as avg_score, responses.survey_id as survey_id", 
  :joins => "right outer join questions on (responses.question_id = questions.id and responses.survey_id =#{params[:id]})
             left outer join sub_sections on questions.sub_section_id = sub_sections.id 
             left outer join sections on sections.id = sub_sections.section_id   
             where sections.id=3",
  :group => "questions.id, responses.id, sections.id, responses.survey_id, questions.name, responses.answer_1, responses.answer_2, responses.answer_3, sections.name, sub_sections.name, questions.points"                         
   ) 
end  

  def reports
  
  end   

#to download in pdf/xls format
def download_result
  require 'rubygems'
  require 'google_chart'
  require 'spreadsheet'  
   
  @survey = Survey.find(params[:id])
  @section_total = []
  @subsection_total = []
  @questions_score = [] 
  @questions_score = []  
  @sections = Section.find(:all) 
  #score for each section and subsection
  @sections.each do |section|
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
  #----graphs and response table-----#
    @responses = Response.find(:all, 
      :select => "questions.name,responses.answer_1, questions.points, sections.name as section_name, sub_sections.name as sub_sect_name", 
      :joins => "right outer join questions on responses.question_id = questions.id 
                 left outer join sub_sections on questions.sub_section_id = sub_sections.id 
                 left outer join sections on sections.id = sub_sections.section_id   
                 and responses.survey_id =#{params[:id]}" 
                 )

  lcs = GoogleChart::LineChart.new("400x200", "My Results", false) do |lcs|
  lcs.data "Line green", [3,5,1,9,0,2], '00ff00'
  lcs.data "Line red", [2,4,0,6,9,3], 'ff0000'
  lcs.axis :y, :range => [0,10], :font_size =>10, :alignment=>"center"
  lcs.show_legend = false
  lcs.shape_marker :circle, :color =>'0000ff', :data_set_index =>0, :data_point_index =>-1, :pixel_size =>10
  @line_graph = lcs.to_url
  @line_graph_strategy = lcs.to_url
  @line_graph_system = lcs.to_url
  @line_graph_programs = lcs.to_url
  end
   
  ####---------------------############
  respond_to do |format|
      format.html{}
       format.pdf {
        html = render_to_string(:layout => false , :action => "reports.html")
        kit = PDFKit.new(html)    
        kit.stylesheets << Rails.root.join("app/assets/stylesheets/jquery.dataTables.css")    
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
