###################################################################################
#
#  Copyright (c) - Icicle Tech. Pvt. Ltd. , Mumbai Copyright © 2009 All rights reserved.
#
#  Redistribution and use in source , with or without
#  modification, are permitted provided that the following conditions
#  are met:
#
#  - Redistributions of source code must retain the above copyright
#    notice.
###################################################################################

=begin

Usage: rake app:setup

Description: Script to Populate the Database during the Development & Demo Stages

Input Parameters:  None

Tables to be Populated: industries, questionnaire, sections, sub_sections, questions

Required gems: activerecord, populator, random_data and highline

=end

#These gems are required before running the script
require 'rubygems'
require 'highline'
require 'database_cleaner'
require 'populator'
require 'faker'

#Not used as of now
DatabaseCleaner.strategy = :truncation

namespace :app do

  desc "Prepare the database and load default application settings"
  task :setup => :environment do
    puts "Preparing Database and load Application Settings"
    if ENV["PROCEED"] != 'true' and ActiveRecord::Migrator.current_version > 0
      puts "\nYour database is about to be reset, so if you choose to proceed all the existing data will be lost.\n\n"
      proceed = false
      loop do
        print "Continue [yes/no]: "
        proceed = STDIN.gets.strip
        break unless proceed.blank?
      end
      return unless proceed =~ /y(?:es)*/i # Don't continue unless user typed y(es)
    end
    Rake::Task["db:migrate:reset"].invoke
    # Migrating plugins is not part of Rails 3 yet, but it is coming. See
    # https://rails.lighthouseapp.com/projects/8994/tickets/2058 for details.
    Rake::Task["db:migrate:plugins"].invoke rescue nil
    #Rake::Task["app:settings:load"].invoke
    #Rake::Task["app:setup:admin"].invoke
    Rake::Task["app:demo:load"].invoke
  end

  namespace :demo do
    desc "Load demo data and default application settings"
    task :load => :environment do
      puts "Load Demo Data and Application Settings"

      $stdout.sync = true
      puts "Setting up Development or demo Database"

    #Create Industries in the Database
      puts "Adding Industries in the application"
      industries = ["Finance","Health Care","Retail","Services","Manufacturing","Comunications"]
      Industry.reset_column_information
      industries.split(",")[0].each_with_index do |industry_name,count|        
       Industry.populate(1) do |industry|
        industry.name     = industry_name
        industry.value    = industry_name
        industry.created_at = Time.now
        industry.updated_at = Time.now
        puts "Industry '#{industry_name}' has been created \n"
       end
      end

    #Create Questionnaires in the Database
      Questionnaire.reset_column_information
      puts "Adding Questionnaires for Application"
        Questionnaire.populate(1) do |questionnaire|
          questionnaire.name = Populator.words(2)
          questionnaire.description = Populator.sentences(3)                   
          questionnaire.is_active   = Random.boolean
          questionnaire.created_at = Time.now
          questionnaire.updated_at = Time.now    
            puts "Questionnaire '#{questionnaire.name}' has been created"
        end

    #Create Sections in the Database
      Section.reset_column_information
      puts "Adding Sections for Application"
        Section.populate(1..10) do |section|          
          section.created_at = Time.now
          section.updated_at = Time.now 
          section.questionnaire_id = Random.number(1..100)
            puts "Section has been created"
        end

    #Create Sub_sections in the Database
      SubSection.reset_column_information
      puts "Adding Sub_sections for Application"
        SubSection.populate(5) do |sub_section|
          sub_section.name = Populator.words(3)
          sub_section.description = Populator.sentences(3)
          sub_section.section_id = Random.number(1..100)  
          sub_section.order = Populator.words(5)        
          sub_section.is_active   = Random.boolean
          sub_section.created_at = Time.now
          sub_section.updated_at = Time.now    
            puts "SubSection '#{sub_section.name}' has been created"
        end

    #Create Questions in the Database
      Question.reset_column_information
      puts "Adding Questions for Application"
        Question.populate(10) do |question|
          question.name = Populator.words(3)          
          question.sequence = Random.number(1..100)                   
          question.is_active   = Random.boolean
          question.sub_section_id = Random.number(1..100)
          question.created_at = Time.now
          question.updated_at = Time.now    
            puts "Questions '#{question.name}' has been created"
        end

      end
    end # End of Namespace demo

end # End of Namespace app

