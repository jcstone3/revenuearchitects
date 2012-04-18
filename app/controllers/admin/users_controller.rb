class Admin::UsersController < ApplicationController
   layout 'admin'
   before_filter :authenticate_admin!

   def index   		
   	    
   	 # @company = Company.find(:all, :select => 'DISTINCT name')
   	 # @industry = Industry.find(:all)
     #   if params[:company_name]
   		#    #@cmp = Company.find(params[:company_id])
     #        @users = User.paginate(:include => :companies, :conditions=>{:companies => {:name => params[:company_name]}},:page=> params[:page], :per_page=>10, :order => "users.id ASC")   		  
   		#    @type_title = "By Company"
   	 #   elsif params[:industry_id]
   	 #   	@users = User.paginate(:include => :companies, :conditions=>{:companies => {:industry_id => params[:industry_id]}},:page=> params[:page], :per_page=>10, :order => "users.id ASC")           
     #        @type_title = "By Industry"
   	 #  else
   	 #  	@users= User.paginate(:page=> params[:page], :per_page=>10, :order => "id ASC")
   	 #  	@type_title = "" 
   	 #  end   
       @user_surveys = User.find(:all,
                       :select => "users.id,users.username, users.email, companies.name as company_name, companies.website as company_website, surveys.size, industries.name as industry_name, surveys.revenue, surveys.start_date",
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
  end
   
end
