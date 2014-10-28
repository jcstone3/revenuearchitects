class SurveysController < ApplicationController

before_filter :authenticate_user!, :check_company #check current_user & company
require 'csv'
include SurveysHelper

layout "application"

def index
  redirect_to continue_survey_path
end
#new survey
#TODO: This action is too complicated, need to simplify this
def new
  @active_survey = []
  @previous_surveys = []
  @response = []
  if current_user.companies.present?#if no company details is provided
      #if current user has company get all the surveys for that company
      @surveys = current_user.companies.first.surveys.order("created_at DESC")

      #check if current incompleted surveys
      @current_surveys = @surveys.select{|survey| survey.is_active == true}

      #no surveys exists then provide the new survey form
      if(@surveys.blank? || @current_surveys.blank?)
         @survey = Survey.new
         @survey_date = Time.now.strftime('%B, %Y')

         #show the previous completed surveys
         @completed_surveys = @surveys.select{|survey| survey.is_active == false}
         @completed_surveys.take(2)

      else
         redirect_to continue_survey_path  and return
      end
  else
    flash[:error] = "Please provide company details before proceeding"
    redirect_to new_company_path  and return
  end
end

#create new survey
def create
  @company = current_user.companies.first
  params[:survey].merge!(:start_date => Time.now, :is_active => true)
  @survey = Survey.new(params[:survey])
  @survey.company = @company
  @user = current_user
  #  @survey = @company.surveys.create!(params[:survey])
  if @survey.save
    @survey_name = @survey.created_at.strftime('%B,%Y')
    #TODO: Need to put the survey in session, even when accessing old survey
    session[:survey] = @survey
    flash[:success] = "Survey #{@survey_name} created successfully"
    begin
      Usermailer.new_signup_details(@user,@company,@survey).deliver
    rescue Exception => e
      logger.info e.message
      logger.info e.backtrace
    end
    redirect_to questions_path(@survey, 1)
  else
    flash[:error] = "Sorry could not create the Survey. Please try again."
    render "new"
  end
end

def edit
  @survey = Survey.find_by_id(params[:id])
  @sizes = [['5000 and above'], ['500-5000'], ['100 - 499'], ['75 - 99'], ['50 - 74'], ['25 - 49'], ['1 - 24']]
end

def update
  @survey = Survey.find_by_id(params[:id])
  if @survey.update_attributes(params[:survey])
    # On comapany updation redirects to the confirm survey
    redirect_to confirm_survey_path
  else
    render :edit
  end
end

def get_response_status
  if !params[:id].blank?
    if params[:id].to_i > 0
    if params[:id].to_i.is_a?(Numeric)
          if check_user_surveys(params[:id])
              response = []
              questions= []
              @survey = Survey.find(params[:id])
              @response = @survey.responses
              company = Company.find(@survey.company_id)


              if @response.present?
                 @response.each do |res|
                   response << res.question_id
                  end
                  logger.debug response
                 question = Question.find(:all,:order => "position")
                 question.each do |quest|
                   questions << quest.id
                 end
                 logger.debug questions
                 res = questions - response
                 @survey_name = @survey.created_at.strftime('%B,%Y')
                 if company.industry_id.present?
                  flash[:success] = "Continue Survey #{@survey_name}"
                 else
                  flash[:success] = "Please complete your survey to view report"
                 end

                  if(!res[0].blank?)
                    redirect_to questions_path(@survey, res[0])
                  else
                    redirect_to confirm_survey_path
                  end
              else
               @survey_name = @survey.created_at.strftime('%B,%Y')
               flash[:success] = "Start Survey #{@survey_name}"
               redirect_to questions_path(@survey, 1)
              end
          else
            flash[:error] = "Some thing went wrong please select a survey"
            redirect_to confirm_survey_path
          end
  else
    flash[:error] = "Something went wrong please select a survey"
    redirect_to continue_survey_path
  end
   else
    flash[:error] = "Something went wrong please select a survey"
    redirect_to continue_survey_path
  end
  else
    flash[:error] = "Something went wrong please select a survey"
    redirect_to continue_survey_path
 end
end

#lists all the active surveys
def show
  @companies =  current_user.companies
  company_ids= @companies.collect(&:id).join(', ')
  #need to get current active and completed surveys
  #first get all surveys for this user and then select for active and inactive
  @get_all_surveys_for_current_user = Survey.get_all_survey_for_user(company_ids)
  @total_question_total = 0
  @total_question_previous = 0
  @survey = Survey.find_by_id(params[:id])
  #current active surveys
  @current_surveys =  @get_all_surveys_for_current_user.select{|survey| survey.is_active == true}

  #completed surveys
  @completed_surveys =  @get_all_surveys_for_current_user.select{|survey| survey.is_active == false}
  @completed_surveys.take(2)
  @sections= Section.all
  #@total_questions = @sections[0].question_count+@sections[1].question_count+@sections[2].question_count
  @section_questions_total = Section.find(:all,
                            :select => "count(questions.position) as question_total, sections.id",
                            :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id Where questions.deleted_at IS NULL",
                            :group => "sections.id", :order => "id ASC")
  # @all_sections = get_all_sections
  @all_sections = Section.order(:sequence)

  @all_sections.each_with_index do |section,i|
    #@final_score += @section_questions[i].question_attempted.to_i
    @total_question_total += @section_questions_total[i].question_total.to_i
  end
  @previous_questions_total = Section.find(:all,
                            :select => "count(questions.position) as question_total, sections.id",
                            :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id ",
                            :group => "sections.id", :order => "id ASC")
  @all_sections.each_with_index do |section,i|
  @total_question_previous += @previous_questions_total[i].question_total.to_i
  end
end

def create_survey
  @companies =  current_user.companies
  @companies.each do |c|
    @company_id = c.id
  end
  @survey = Survey.create(company_id: "#{@company_id}", is_active: true, start_date: Time.now)
  redirect_to questions_path(@survey, 1)
end


#Show the question and capture the reponse
def question
  survey_id = params[:id]
  question_id = params[:question_id]
  #question_id  =  Question.where(:id => question_id).pluck("position")[0]

  #TODO: Check if input parameters are correct
  if survey_id.blank? or question_id.blank?
   flash[:warning] = "Could not form the question. Please try again"
   redirect_to continue_survey_path
  end

  #Get current Survey
  @survey = Survey.find_by_id(survey_id)
  session[:survey] = Survey.find_by_id(params[:id])

  #Check if the there is question in the survey. If question exists, get the following
  # - Question
  # - Current Section
  # - Current Subsection
  # - Array for Pagination of Questions
  # - All Sections
  # - All Subsections
  @question = get_question(question_id)

  if @survey.blank?
    flash[:warning] = "Could not form the question. Please try again"
    redirect_to continue_survey_path and return
  end

  if @question.blank?
    @question = get_question(question_id)
    if @survey.company.name.present? && @survey.company.industry.present?
      redirect_to edit_survey_path(id: survey_id)
      # redirect_to confirm_survey_path and return
    else
      redirect_to edit_company_path(id: @survey.company.id)
    end
  end

  #for total count
  @section_questions_total = Section.find(:all,
        :select => "count(questions.position) as question_total, sections.id",
        :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id Where questions.deleted_at IS NULL",
        :group => "sections.id", :order => "id ASC")

  @section_questions  = Section.find(:all,
         :select => "count(responses.question_id) as question_attempted",
         :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id left outer join responses on (responses.question_id = questions.id and responses.survey_id=#{params[:id]})",
         :group => "sections.id", :order => "sections.id")
  # @all_sections = get_all_sections
  @all_sections = Section.order(:sequence)


  #Getting the score to show on page
  @total_score = Survey.calculate_response_for_section(survey_id, @question.section_id) if @question.present?

  #Required for form. Select if the response already exists
  @response = Response.find_by_survey_id_and_question_id(survey_id, @question.id) if @question.present?

  if Response.find_by_survey_id(survey_id).present? || current_user.popup_status == false
    cookies[:popup_model] = false
  else
    cookies[:popup_model] = true
  end

  if @response.blank?
    logger.debug "Creating New Response"
    @response = Response.new
  end

  if params[:question_id].present?
    @survey_question = Question.find_by_position(params[:question_id])
    if @survey_question.present?
      @sub_section = SubSection.includes(:section).where(:id => @survey_question.sub_section_id).first
      @section = Section.select(:name).where(:id => @sub_section.section_id).first
      @sub_section_name =  @survey_question.sub_section.name.titleize
      @section_name = @survey_question.sub_section.section.name.titleize
    end
  end
  @response
end


#TODO: Check the logic here and optimize
def create_response
  #Once the response is submitted, depending on whether Score exists,
  # create or update the record

  response_params = params[:response]

  if response_params.blank?
    flash[:error] = "Could not save response. Please try again"
    redirect_to continue_survey_path and return
  end

   #Create a response if new or update the existing record
   survey_id = response_params[:survey_id]
   #question_id = params[:question_id]
   question_id = response_params[:question_id]
   @response = Response.find_by_survey_id_and_question_id(survey_id, question_id)

   if @response.blank?
    @response = Response.new
  end

   if @response.update_attributes(response_params)
    #TODO: Redirect to next page. Issue with sequence.
    #Find if the question is the last of the questions. If it is, then go to close survey, else go
    #go to next question

    redirect_to questions_path(survey_id, params[:question_id].to_i + 1 ) and return
    #redirect_to questions_path(survey_id, question_id) and return
  else
    flash[:error] = "Error in saving the Response. Please try again."
    redirect_to questions_path(survey_id, question_id) and return
  end
end

#question for the survey
# def question
#    if params[:id].present? && params[:question_id].present?
#      if((Survey.check_numericality(params[:id])) && (check_survey(params[:id])))
#        if check_user_surveys(params[:id])
#           @survey = Survey.find(params[:id])
#           @response = @survey.responses
#            if((Survey.check_numericality(params[:question_id])) && (check_question(params[:question_id])))

#              @survey_response = Response.find_by_survey_id_and_question_id(params[:id], params[:question_id])
#               if @survey_response
#                redirect_to previous_question_path(params[:id], params[:question_id])
#               else
#                 @question = Question.find(params[:question_id])
#                 @sub_section = SubSection.find(@question.sub_section_id)
#                 @section = Section.find(@sub_section.section_id)
#                 @allSection = Section.all

#                 @response = Response.new
#                 @total_score = Survey.calculate_response_for_section(params[:id], @section.id)
#                 ########for pagination ############

#                 @question_all = Question.count
#                 if(params[:question_id].to_i < 6)
#                 @questions = Question.find(:all,
#                        :select => "questions.id, responses.question_id as response_quest_id",
#                        :joins => "left outer join responses on responses.question_id = questions.id and responses.survey_id=#{params[:id]}",
#                        :offset=> 0, :limit=>10 )

#                 elsif(params[:question_id].to_i > @question_all - 5)
#                 @questions = Question.find(:all,
#                        :select => "questions.id, responses.question_id as response_quest_id",
#                        :joins => "left outer join responses on responses.question_id = questions.id and responses.survey_id=#{params[:id]}",

#                        :offset=> (@question_all - 10), :limit=>10 )
#                 else
#                 @questions = Question.find(:all,
#                        :select => "questions.id, responses.question_id as response_quest_id",
#                        :joins => "left outer join responses on responses.question_id = questions.id and responses.survey_id=#{params[:id]}",

#                        :offset=> (params[:question_id].to_i - 5), :limit=>10)
#                 end
#                 ######### end of pagination logic ##########
#               end
#            else
#             flash[:error] = "Something went wrong please select a survey"
#             redirect_to continue_survey_path
#            end
#       else
#        flash[:error] = "Something went wrong please select a survey"
#        redirect_to continue_survey_path
#       end
#     else
#       flash[:error] = "Something went wrong please select a survey"
#       redirect_to continue_survey_path
#     end
#    else
#      flash[:error] = "Something went wrong please select a survey"
#      redirect_to continue_survey_path
#    end
# end

#report of a particular survey
def report
  survey_id = params[:id]

  #scoping the survey
  @survey = current_user.companies.first.surveys.find_by_id(survey_id)

  company = Company.find(@survey.company_id)
  if company.industry_id.present?
    if @survey.blank?
       flash[:notice] = "No such survey exists"
       redirect_to new_survey_path and return
     else
      #for sections navigation tabs
      @all_sections = Section.order(:sequence)

      #if the user is authorized for the survey then get details of all responses
       @all_responses = Response.get_all_responses(@survey.id)
       @all_responses_for_strategy = Response.get_response(1, @survey.id)
       @all_responses_for_system = Response.get_response(2, @survey.id)
       @all_responses_for_program = Response.get_response(3, @survey.id)
      #if the user is authorized for the survey then get details of add to plan responses
       @add_to_plan_responses = Response.get_response_for_options(@survey.id, "add_to_plan")
      #for must do responses
       @must_do_responses = @add_to_plan_responses.select{|response| response.answer_3 == 'must_do'}
      #for should do responses
       @should_do_responses = @add_to_plan_responses.select{|response| response.answer_3 == 'should_do'}
      #for could do responses
       @could_do_responses = @add_to_plan_responses.select{|response| response.answer_3 == 'could_do'}

      #for total count
       @section_questions_total = Section.find(:all,
                              :select => "count(questions.position) as question_total, sections.id",
                              :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id Where questions.deleted_at IS NULL",
                              :group => "sections.id", :order => "id ASC")

       #for section questions attempted
       @section_questions  = Section.find(:all,
                             :select => "count(responses.question_id) as question_attempted",
                             :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id left outer join responses on (responses.question_id = questions.id and responses.survey_id=#{params[:id]})",
                             :group => "sections.id", :order => "sections.id")

        # render :layout =>"report"

        # Generate per section score
        @score_per_section = Survey.calculate_score_for_section(survey_id)
        @total_score_per_section = @score_per_section[0] + @score_per_section[1] + @score_per_section[2]
        @total_all_sections_points = @all_sections[0].total_points.to_i + @all_sections[1].total_points.to_i + @all_sections[2].total_points.to_i


      respond_to do |format|
        format.html {render :layout => "report"}
        format.pdf do
          pdf =  render_to_string(:pdf => "RevenueGrader survey report #{DateTime.now.strftime('%b %d %Y')}.pdf", :template => '/surveys/reports_in_pdf.html.erb', orientation: 'Landscape', :layouts => false)
          send_data pdf, filename: "RevenueGrader survey report #{DateTime.now.strftime('%b %d %Y')}.pdf"
        end
      end

    end
  else
    redirect_to get_response_status_url(@survey)
  end
end

def import_excel
  survey_id = params[:id]
  @survey = current_user.companies.first.surveys.find_by_id(survey_id)
  @diagnostic_for = @survey.created_at.strftime('%d %B  %Y')
  @all_responses = Response.get_all_responses(@survey.id)
  headers["Content-Disposition"] = "attachment; filename=\"#{current_user.companies.first.name.humanize}_#{@diagnostic_for}.xls\""
  respond_to do |format|
    format.xls { render :report }
  end
end

def import_csv
  survey_id = params[:id]
  @survey = current_user.companies.first.surveys.find_by_id(survey_id)
  @diagnostic_for = @survey.created_at.strftime('%d %B  %Y')
  @all_responses = Response.get_all_responses(@survey.id)
  headers["Content-Disposition"] = "attachment; filename=\"#{current_user.companies.first.name.humanize}_#{@diagnostic_for}.csv\""


  csv_string = CSV.generate do |csv|
    csv << ["#", "Questions", "Section", "Subsection", "Points", "Your Score", "Avg Score", "Cal Score", "Avg Cal Score", "Priority"]
    @all_responses.each do |response|
      csv << [response.questions_id, response.name, response.section_name.try(:titleize), response.sub_sect_name.try(:titleize), response.points, response.score, response.response_id.present? ? get_average_score(response.questions_id, response.survey_id) : 0, response.response_id.present? ? get_calculated_score(response.response_id, response.questions_id) : 0, response.response_id.present? ? get_avg_calculated_score(response.survey_id, response.questions_id, response.section_id) : 0, response.answer_3.try(:titleize)]
    end
  end
  respond_to do |format|
    format.csv { send_data csv_string, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=#{current_user.companies.first.name.humanize}_#{@diagnostic_for}.csv" }
  end
end

def update_response
  if params[:response].blank?
    flash[:error] = "Could not save response for some reason please try again"
    redirect_to continue_survey_path
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
      redirect_to questions_path(@survey, @question.id)
   else
     redirect_to confirm_survey_path(@survey.id)
   end
  end
end

def confirm_survey
  @questions=[]
  @final_score = 0
  @total_question_total = 0
  @survey = Survey.find_by_id(params[:id])
  #for total count
   @section_questions_total = Section.find(:all,
                          :select => "count(questions.position) as question_total, sections.id",
                          :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id Where questions.deleted_at IS NULL",
                          :group => "sections.id", :order => "id ASC")

  @section_questions  = Section.find(:all,
                           :select => "count(responses.question_id) as question_attempted",
                           :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id left outer join responses on (responses.question_id = questions.id and responses.survey_id=#{params[:id]})",
                           :group => "sections.id", :order => "sections.id")
  logger.debug "#{@section_questions}"
  # @all_sections = get_all_sections
  @all_sections = Section.order(:sequence)


  @all_sections.each_with_index do |section,i|
    @final_score += @section_questions[i].question_attempted.to_i
    @total_question_total += @section_questions_total[i].question_total.to_i
  end
 end

def close_survey
   @survey = Survey.find_by_id(params[:id])
   if @survey.update_attribute(:is_active, false)
     flash[:success] = "Thank you for taking up the survey"
     redirect_to reports_path(params[:id])
   else
     flash[:success] = "Sorry could not close the survey"
     redirect_to confirm_survey_path(@survey.id)
   end
end

def compare
  survey_id = params[:id]
  # @all_sections = get_all_sections
  @all_sections = Section.order(:sequence)

  #check scope

   #scoping the survey
  @survey = current_user.companies.first.surveys.find_by_id(survey_id)

  #for section questions attempted
   @section_questions  = Section.find(:all,
                           :select => "count(responses.question_id) as question_attempted",
                           :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id left outer join responses on (responses.question_id = questions.id and responses.survey_id=#{params[:id]})",
                           :group => "sections.id", :order => "sections.id")

   #for total count
  @section_questions_total = Section.find(:all,
                            :select => "count(questions.position) as question_total, sections.id",
                            :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id Where questions.deleted_at IS NULL",
                            :group => "sections.id", :order => "id ASC")

  if @survey.blank?
     flash[:notice] = "No such survey exists"
     redirect_to new_survey_path and return
   else
    @survey = Survey.find_by_id(survey_id)
    @data_table = Survey.get_overall_graph(survey_id)

     option = { width: 1200, height: 400, pointSize: 4, title: 'Your Score Vs Average Score', lineWidth: '3', hAxis: {showTextEvery: '5',title: 'Questions', titleTextStyle: {color: '#000',fontName: 'Lato'}}, vAxis: {title: 'Score', titleTextStyle: {color: '#000',fontName: 'Lato'}} }
    @chart = GoogleVisualr::Interactive::AreaChart.new(@data_table, option)

    @responses = Response.get_all_responses(@survey.id)
  end
  render :layout =>"report"
end

def compare_strategy
  survey_id = params[:id]
  # @all_sections = get_all_sections
  @all_sections = Section.order(:sequence)

  #check scope

   #scoping the survey
  @survey = current_user.companies.first.surveys.find_by_id(survey_id)

  #for total count
     @section_questions_total = Section.find(:all,
                            :select => "count(questions.position) as question_total, sections.id",
                            :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id Where questions.deleted_at IS NULL",
                            :group => "sections.id", :order => "id ASC")


  #for section questions attempted
      @section_questions  = Section.find(:all,
                           :select => "count(responses.question_id) as question_attempted",
                           :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id left outer join responses on (responses.question_id = questions.id and responses.survey_id=#{params[:id]})",
                           :group => "sections.id", :order => "sections.id")
   #scoping the survey
  @survey = current_user.companies.first.surveys.find_by_id(survey_id)


  if @survey.blank?
     flash[:notice] = "No such survey exists"
     redirect_to new_survey_path and return
   else
  @survey = Survey.find(params[:id])
  @responses = Survey.get_result(@all_sections[0].id, @survey.id)
  @data_table = Survey.get_section_graph(@all_sections[0].id, @survey.id, @responses)

  logger.debug "&&&&&&&&&&& datatable is "
  logger.debug @data_table.inspect

  option = { width: 1200, height: 400, pointSize: 4, title: 'Your Score Vs Average Score',lineWidth: '3', hAxis: {showTextEvery: '2',title: 'Questions', titleTextStyle: {color: '#000',fontName: 'Lato'}}, vAxis: {title: 'Score', titleTextStyle: {color: '#000',fontName: 'Lato'}} }
  @chart = GoogleVisualr::Interactive::AreaChart.new(@data_table, option)
  end
    render :layout =>"report"
end


def compare_system
  survey_id = params[:id]
  # @all_sections = get_all_sections
  @all_sections = Section.order(:sequence)

  #check scope

  #scoping the survey
  @survey = current_user.companies.first.surveys.find_by_id(survey_id)
  #for section questions attempted
    @section_questions  = Section.find(:all,
                           :select => "count(responses.question_id) as question_attempted",
                           :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id left outer join responses on (responses.question_id = questions.id and responses.survey_id=#{params[:id]})",
                           :group => "sections.id", :order => "sections.id")

    #for total count
     @section_questions_total = Section.find(:all,
                            :select => "count(questions.position) as question_total, sections.id",
                            :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id Where questions.deleted_at IS NULL",
                            :group => "sections.id", :order => "id ASC")

  if @survey.blank?
     flash[:notice] = "No such survey exists"
     redirect_to new_survey_path and return
   else

  @survey = Survey.find(params[:id])
  @responses = Survey.get_result(@all_sections[1].id, @survey.id)
  @data_table = Survey.get_section_graph(@all_sections[1].id, @survey.id, @responses)


 option = { width: 1200, height: 400, pointSize: 4, title: 'Your Score Vs Average Score',lineWidth: '3', hAxis: {showTextEvery: '2',title: 'Questions', titleTextStyle: {color: '#000',fontName: 'Lato'}}, vAxis: {title: 'Score', titleTextStyle: {color: '#000',fontName: 'Lato'}} }
  @chart = GoogleVisualr::Interactive::AreaChart.new(@data_table, option)


end
    render :layout =>"report"

end


def compare_programs
  survey_id = params[:id]
  # @all_sections = get_all_sections
  @all_sections = Section.order(:sequence)

  #check scope

   #scoping the survey
   @survey = current_user.companies.first.surveys.find_by_id(survey_id)

   #for total count
     @section_questions_total = Section.find(:all,
                            :select => "count(questions.position) as question_total, sections.id",
                            :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id Where questions.deleted_at IS NULL",
                            :group => "sections.id", :order => "id ASC")


   #for section questions attempted
      @section_questions  = Section.find(:all,
                           :select => "count(responses.question_id) as question_attempted",
                           :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id left outer join responses on (responses.question_id = questions.id and responses.survey_id=#{params[:id]})",
                           :group => "sections.id", :order => "sections.id")

  if @survey.blank?
     flash[:notice] = "No such survey exists"
     redirect_to new_survey_path and return
   else
  @survey = Survey.find(survey_id)
  @responses = Survey.get_result(@all_sections[2].id, @survey.id)
  @data_table = Survey.get_section_graph(@all_sections[2].id, @survey.id, @responses)

  option = { width: 1200, height: 400, pointSize: 4, title: 'Your Score Vs Average Score',lineWidth: '3', hAxis: {showTextEvery: '2',title: 'Questions', titleTextStyle: {color: '#000',fontName: 'Lato'}}, vAxis: {title: 'Score', titleTextStyle: {color: '#000',fontName: 'Lato'}} }
  @chart = GoogleVisualr::Interactive::AreaChart.new(@data_table, option)


end
    render :layout =>"report"

end

 def reports

  @sections = Section.find(:all)
  survey_id = params[:id]
  @survey = current_user.companies.first.surveys.find(params[:id])
  @industry = Industry.find(:first, :select=>"industries.name",
               :joins=>"left outer join companies on companies.industry_id = industries.id
                       left outer join surveys on companies.id = surveys.company_id and
                       surveys.id = #{@survey.id}")


  if @survey.blank?
     flash[:notice] = "No such survey exists"
     redirect_to new_survey_path and return
   else
    #for sections navigation tabs
    # @all_sections = get_all_sections
    @all_sections = Section.order(:sequence)

    #if the user is authorized for the survey then get details of add to plan responses
     @add_to_plan_responses = Response.get_response_for_options(@survey.id, "add_to_plan")
    #for must do responses
     @must_do_responses = @add_to_plan_responses.select{|response| response.answer_3 == 'must_do'}
    #for should do responses
     @should_do_responses = @add_to_plan_responses.select{|response| response.answer_3 == 'should_do'}
    #for could do responses
     @could_do_responses = @add_to_plan_responses.select{|response| response.answer_3 == 'could_do'}
    #if the user is authorized for the survey then get details of not applicable responses
     @not_applicable_responses = Response.get_response_for_options(@survey.id, "not_applicable")
    #if the user is authorized for the survey then get details of in plan responses
     @in_plan_responses = Response.get_response_for_options(@survey.id, "in_plan")
     @survey = Survey.find_by_id(survey_id)
      @data_table = Survey.get_overall_graph(survey_id)
  option = { width: 600, height: 400, pointSize: 4, title: 'Your Score Vs Average Score', lineWidth: '3', hAxis: {showTextEvery: '5',title: 'Questions', titleTextStyle: {color: '#000',fontName: 'Lato'}}, vAxis: {title: 'Score', titleTextStyle: {color: '#000',fontName: 'Lato'}} }
  @chart = GoogleVisualr::Interactive::AreaChart.new(@data_table, option)
  end

 end

#to download in pdf/xls format
def download_result
  require 'rubygems'
  #require 'googlecharts'
  require 'spreadsheet'

   @sections = Section.find(:all)
   @survey = current_user.companies.first.surveys.find(params[:id])
   @industry = Industry.find(:first, :select=>"industries.name",
               :joins=>"left outer join companies on companies.industry_id = industries.id
                       left outer join surveys on companies.id = surveys.company_id and
                       surveys.id = #{@survey.id}")

  @questions=[]
  @final_score = 0
  @total_question_total = 0
  #@survey = Survey.find_by_id(params[:id])
  #for total count
   @section_questions_total = Section.find(:all,
                          :select => "count(questions.position) as question_total, sections.id",
                          :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id Where questions.deleted_at IS NULL",
                          :group => "sections.id", :order => "id ASC")

  @section_questions  = Section.find(:all,
                           :select => "count(responses.question_id) as question_attempted",
                           :joins => "left outer join sub_sections on sections.id = sub_sections.section_id left outer join questions on questions.sub_section_id = sub_sections.id left outer join responses on (responses.question_id = questions.id and responses.survey_id=#{params[:id]})",
                           :group => "sections.id", :order => "sections.id")
  logger.debug "#{@section_questions}"
    @all_sections = get_all_sections
    @all_sections.each_with_index do |section,i|
    @final_score += @section_questions[i].question_attempted.to_i
    @total_question_total += @section_questions_total[i].question_total.to_i
  end

  if @survey.blank?
     flash[:notice] = "No such survey exists"
     redirect_to new_survey_path and return
   else
    #for sections navigation tabs
    @all_sections = get_all_sections

    #if the user is authorized for the survey then get details of add to plan responses
     @add_to_plan_responses = Response.get_response_for_options(@survey.id, "add_to_plan")
    #for must do responses
     @must_do_responses = @add_to_plan_responses.select{|response| response.answer_3 == 'must_do'}
    #for should do responses
     @should_do_responses = @add_to_plan_responses.select{|response| response.answer_3 == 'should_do'}
    #for could do responses
     @could_do_responses = @add_to_plan_responses.select{|response| response.answer_3 == 'could_do'}
    #if the user is authorized for the survey then get details of not applicable responses
     @not_applicable_responses = Response.get_response_for_options(@survey.id, "not_applicable")
    #if the user is authorized for the survey then get details of in plan responses
     @in_plan_responses = Response.get_response_for_options(@survey.id, "in_our_plan")


    @data_table = Survey.get_overall_graph(@survey.id)
    option = { width: 1000, height: 600, title: 'Your Score Vs Average Score',lineWidth: '3', hAxis: {showTextEvery: '5',title: 'Questions', titleTextStyle: {color: '#000',fontName: 'Lato'}}, vAxis: {title: 'Score', titleTextStyle: {color: '#000',fontName: 'Lato'}} }
    @chart = GoogleVisualr::Interactive::AreaChart.new(@data_table, option)

  end

  respond_to do |format|
      format.html{}
       format.pdf {
        html = render_to_string(:layout => false , :action => "reports.html")
        kit = PDFKit.new(html)
        kit.stylesheets << Rails.root.join("app/assets/stylesheets/jquery.dataTables.css")
        kit.stylesheets << Rails.root.join("app/assets/stylesheets/application.css")
        send_data(kit.to_pdf, :filename =>  "#{current_user.companies.first.name.humanize} #{@survey.created_at.strftime('%B %Y')} Diagnostic Report.pdf", :type => 'application/pdf')
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

  def sub_section
    sub_section = SubSection.find_by_name(params[:sub_section_name].strip)
    current_survey = session[:survey]
    if current_survey.is_active == false
      current_survey = nil
    end

    respond_to do |format|
      format.json {render json: {current_survey: current_survey, question_id: sub_section.questions.first.id}}
    end
  end

def prevent_popup
  @user = User.find_by_id(current_user.id)
  @user.update_attribute(:popup_status, params[:checked])
  if @user.popup_status == false
    cookies.delete :popup_model
  end
  render text: "OK"
end

private
def check_company
  if !current_user.companies
     redirect_to new_company_path
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
  @question = Question.find_by_position(question_id)
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

#Get all sections and store them in session
def get_all_sections
  all_sections = session[:all_sections]

  if all_sections.blank?
    all_sections = Section.order(:sequence)
    session[:all_sections] = all_sections
  end
  all_sections
end

#Get the current survey based on the query parameters passed.
#TODO: Check if this works when query parameters are not passed
def get_current_survey
  current_survey = session[:survey]
  if current_survey.blank?
    current_survey = current_user.companies.first.surveys.find_by_id(params[:id])
    session[:survey] = current_survey
  end

  current_survey
end

#Get the current question from Session
# If Current Question is not found, run the query
def get_question(question_id)
  questions = session[:questions]
  if questions.blank?
    questions = Question.select("questions.id, questions.position, questions.name, questions.points, questions.description as description, sections.name as section_name, sub_sections.name as sub_section_name, sections.id as section_id, sections.total_points as total_points").joins(:sub_section => :section).order("questions.sequence ASC")
    session[:questions] = questions
  end
  question = questions.select { |quest|  quest.position == question_id.to_i }

  if question.present?
    return question.first
  else
    return question
 end
end

end
