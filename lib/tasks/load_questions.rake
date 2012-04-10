#load actual sections, subsections and questions in the application

namespace :survey do

desc "Load Questionairre set, sections, subsections and questions in the database"
task :load_data => :environment do
	puts "Load Questionairre set for the survey"
	Rake::Task["survey:load_question_set"].invoke
	puts "Load Sections for the survey"
	
	puts "Load subsections set for the survey"
	puts "Load Questions for the survey"

end


desc "Load Questionnaire set for the survey"
task :load_question_set => :environment do 
puts "Uploading Question Set in the database"
open("#{Rails.root}/db/question_set.csv") do |question_set|
    	question_set.read.each_line do |qs|
    	name,description = qs.chomp.split(",")
    	questionnaire = Questionnaire.new(:name => name, :description => description)
    	questionnaire.save!
    end
end

end
	
end