module SurveysHelper
   def get_calculated_score(response_id, response_question_id)
     @response_score = Survey.get_individual_response_score(response_id, response_question_id)
    end

    def get_avg_calculated_score(response_survey_id, response_questions_id, section_id)
       @avg_response_score = Survey.get_average_calculated_score(response_survey_id, response_questions_id, section_id)
    end   

    def get_graph(section_id, survey_id)
      @line_graph = Survey.get_section_graph(section_id, survey_id)
    end 
    
    def get_overallgraph(survey_id)
       @line_graph = Survey.get_overall_graph(survey_id)
    end

    def get_response_result(section_id, surveyid)
      @responses = Survey.get_result(section_id, surveyid)
    end

    def get_response_result_actions(surveyid, action)
      @responses = Survey.get_result_action(surveyid, action)
    end 
end
