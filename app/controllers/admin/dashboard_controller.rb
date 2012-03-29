class Admin::DashboardController < Admin::ApplicationController
   layout 'admin'
   before_filter :authenticate_admin!, :expect=> [:index]
	def index
	end	

	def show
	end	
end
