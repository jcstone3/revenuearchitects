class Admin::DashboardController < Admin::ApplicationController
   layout 'admin'
   before_filter :authenticate_admin!
	def index
	end	

	def show
	end	
end
