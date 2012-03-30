class Admin::DashboardController < Admin::ApplicationController
   layout 'admin'
   before_filter :authenticate_admin!, :except=> [:index]
	def index
	end	

	def show
	end	
end
