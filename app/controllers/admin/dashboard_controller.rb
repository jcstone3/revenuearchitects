class Admin::DashboardController < Admin::ApplicationController
   layout 'admin'
   before_filter :authenticate_admin!
	def index

		#retrieves total survey day wise
		@total_surveys = Survey.find(:all, 
						 :select => "count(id) as total, to_char(start_date, 'd') as survey_day",
						 :conditions => "start_date between date_trunc('month', current_date) and date_trunc('month', current_date)+'1month'::interval-'1day'::interval",
						 :group => "survey_day")

		@total = Survey.find(:all, 
							 :select => "count(id) as total",
							  :conditions => "start_date between date_trunc('month', current_date) and date_trunc('month', current_date)+'1month'::interval-'1day'::interval"
							).first.total
		
	end	

	def show
	end	
end
