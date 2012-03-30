class Admin::UsersController < ApplicationController
   layout 'admin'
   before_filter :authenticate_admin!

   def index
   	@users= User.paginate(:page=> params[:page], :per_page=>10)
   	@company = Company.find(:all)
   	@industry = Industry.find(:all)
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
end
