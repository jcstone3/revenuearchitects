module SurveyHelper

	def get_calculated_score(response_id, response_question_id)
	 @response_score = Survey.get_individual_response_score(response_id, response_question_id)
	end

    def get_avg_calculated_score(response_survey_id, response_questions_id)
       @avg_response_score = Survey.get_avg_calculated_score(response_survey_id, response_questions_id)
    end 	
end
