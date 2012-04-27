#load actual sections, subsections and questions in the application

namespace :survey do

desc "Load Questionairre set, sections, subsections and questions in the database"
task :load_data => :environment do
	puts "Load Questionairre set for the survey"
	Rake::Task["survey:load_question_set"].invoke
	puts "Load Sections for the survey"
	Rake::Task["survey:load_sections"].invoke
	puts "Load subsections set for the survey"
	Rake::Task["survey:load_sub_sections"].invoke
	puts "Load Questions for the survey"
	Rake::Task["survey:load_questions"].invoke

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


desc "Load Sections for the survey"
task :load_sections => :environment do 
question_set_id = Questionnaire.first.id	
puts "Uploading Sections in the database"
open("#{Rails.root}/db/sections.csv") do |sections|
    	sections.read.each_line do |section|
    	name = section.chomp
    	section = Section.new(:name => name, :questionnaire_id => question_set_id)
    	section.save!
    end
 end
end


desc "Load Sub Sections set for the survey"
task :load_sub_sections => :environment do 
@sections = Section.find(:all)
puts "Uploading Sub Sections Set in the database"
open("#{Rails.root}/db/sub_sections.csv") do |sub_sections|
    	sub_sections.read.each_line do |sub_section|
    	name,description,section = sub_section.chomp.split(",")
    	section_id = @sections.select {|sec| sec.name.downcase == section.downcase }.first.id
		sub_section = SubSection.new(:name => name, :description => description, :section_id => section_id)
    	sub_section.save!
    end
 end
end


desc "Load Questionnaire set for the survey"
task :load_questions => :environment do 
@sub_sections = SubSection.find :all
sequence = 0
puts "Uploading Question Set in the database"
open("#{Rails.root}/db/questions.csv") do |questions|
    	questions.read.each_line do |question|
    	sequence = sequence + 1	
    	name,description,sub_section,points = question.chomp.split(":")
        puts sub_section.downcase
        p "in subsection"
    	sub_section_id = @sub_sections.select {|sec| sec.name.downcase == sub_section.downcase }.first.id
    	p "#{sub_section_id}"
        question = Question.new(:name => name, :description => description, :sequence => sequence, :is_active => true, :sub_section_id => sub_section_id, :points => points)
    	question.save!
    end
 end

@section = Section.find(1)
@section.update_attributes(:question_count=>30, :total_points=>100, :sequence => 1) 
@section = Section.find(2)
@section.update_attributes(:question_count=>40, :total_points=>100, :sequence => 2)
@section = Section.find(3)
@section.update_attributes(:question_count=>30, :total_points=>100, :sequence => 3)
 
end

#update question count and points in sections table

# @sections = Section.find :all

# @sections.each do |section|


# end

	
end