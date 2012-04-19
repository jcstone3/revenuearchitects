class Admin::UsersController < ApplicationController
   layout 'admin'
   before_filter :authenticate_admin!

   def index   		  	    
   	 
       @user_surveys = User.find(:all,
                       :select => "users.id,users.username, users.email, companies.name as company_name, companies.website as company_website, surveys.size, industries.name as industry_name, surveys.revenue, surveys.start_date, surveys.id as survey_id",
                       :joins => "left outer join companies on users.id = companies.user_id left outer
                                 join surveys on companies.id = surveys.company_id inner join industries on
                                 companies.industry_id = industries.id" ,
                       :order => "start_date desc" )

   	respond_to do |format|
   		format.js {render :layout => false}
   		format.html 
   	end
   end	

   def activate_user
   	@user = User.find_by_id(params[:id])
      if @user.update_attribute(:is_active, true)   
       flash[:success] = "User #{@user.username} activated successfully"
       redirect_to admin_users_url
      else
       flash[:success] = "Sorry could not deactivated the user"  
       redirect_to admin_users_url
      end 
   end	


   def deactivate_user
      @user = User.find_by_id(params[:id])
     if @user.update_attribute(:is_active, false)      
      flash[:success] = "User #{@user.username} deactivated successfully"
      redirect_to admin_users_url
      else
       flash[:success] = "Sorry could not activated the user"  
       redirect_to admin_users_url
      end  
   end

  def survey_report
    @user = User.find_by_id(params[:id])
    @survey = Survey.find(params[:survey_id])
    if @survey.present?
      @section_total = []
      @subsection_total = []
      @questions_score = [] 
      @questions_score = []  
      @sections = Section.find(:all) 
      #score for each section and subsection
      @sections.each do |section|
         @section_total << Survey.calculate_response_for_section(params[:survey_id], section.id)
         section.sub_sections.each do |sub_section|     
         @subsection_total << Survey.calculate_response_for_subsection(params[:survey_id], sub_section.id)
        end
      end
      @final_score = @section_total[0]+@section_total[1]+@section_total[2]
      #get the individual response score
      @survey.responses.each do |response|
        @questions_score << Survey.get_individual_response_score(response.id, response.question_id)
      end        
       
    else
     redirect_to :index     
    end
 end  
end
