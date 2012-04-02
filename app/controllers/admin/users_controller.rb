class Admin::UsersController < ApplicationController
   layout 'admin'
   before_filter :authenticate_admin!

   def index   		
   	    
   	 @company = Company.find(:all, :select => 'DISTINCT name')
   	 @industry = Industry.find(:all)
       if params[:company_name]
   		   #@cmp = Company.find(params[:company_id])
            @users = User.paginate(:include => :companies, :conditions=>{:companies => {:name => params[:company_name]}},:page=> params[:page], :per_page=>5)   		  
   		   @type_title = "By Company"
   	   elsif params[:industry_id]
   	   	@users = User.paginate(:include => :companies, :conditions=>{:companies => {:industry_id => params[:industry_id]}},:page=> params[:page], :per_page=>5)           
            @industry = Industry.find(params[:industry_id])
   		   @type_title = "By Industry"
   	  else
   	  	@users= User.paginate(:page=> params[:page], :per_page=>10)
   	  	@type_title = "" 
   	  end   
   	respond_to do |format|
   		format.js {render :layout => false}
   		format.html 
   	end	
   	 

   end	

   def edit
   	@user = User.find(params[:id])
   end	


   def update
    @user = User.find(params[:id])     
    if @user.update_attributes(params[:user])        	
      flash[:success] = "User updated successfully"
      redirect_to admin_users_url
    else
      flash[:error] = "Sorry user could not be updated"
      render :edit  
    end	
   end

   def update_user
   	
   		
    end	
end
