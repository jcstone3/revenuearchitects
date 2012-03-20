require 'rubyXL'

task :parse_XL  => :environment do 	

    	workbook = RubyXL::Workbook.new
    	workbook = RubyXL::Parser.parse("/home/icicle/Revenue_Grader_Scorecard.xlsx")

    ActiveRecord::Base.transaction do
      
    	@questionnaire = Questionnaire.new
    	@questionnaire.name = workbook[2][5][0].value
    	@questionnaire.save
      
      @section = Section.new      
      @section.questionnaire_id = @questionnaire.id
      @section.save
     
      #########################SubSections starts here#########
      temp = ""
      workbook.worksheets[2].each do |row|  #Reading data from Questions-Systems sheet 
        unless row[1].nil?
          if (row[1].value != temp and row[1].value != "Segment")          
            @sub_section = SubSection.new
            @sub_section.name = workbook[2][5][1].value
            @sub_section.section_id = @section.id
            @sub_section.save   
            for i in 5..51
              @question = Question.new
              break if workbook[2][i][4].value.nil? 
              @question.name = workbook[2][i][4].value 
              @question.sub_section_id = @sub_section.id
              @question.save  
            end   #for end
            temp = row[1].value
          end # if end
        end #unless end
      end #worksheet loop end
      ######################################################3
    end
end