module SurveysHelper
   def get_calculated_score(response_id, response_question_id)
     @response_score = Survey.get_individual_response_score(response_id, response_question_id)
    end

    def get_avg_calculated_score(response_survey_id, response_questions_id, section_id)
       @avg_response_score = Survey.get_average_calculated_score(response_survey_id, response_questions_id, section_id)
    end

    # def get_graph(section_id, survey_id)
    #   @line_graph = Survey.get_section_graph(section_id, survey_id)
    # end

    def get_overallgraph(survey_id)
       @line_graph = Survey.get_overall_graph(survey_id)
    end

    def get_response_result(section_id, surveyid)
      @responses = Survey.get_result(section_id, surveyid)
    end

    def get_response_result_actions(surveyid, action)
      @responses = Survey.get_result_action(surveyid, action)
    end

    #Average score for question from other companies of same industry
    def get_average_score(response_questions_id, response_survey_id)
      @average_score = Survey.get_average_score_from_other_companies(response_questions_id, response_survey_id)
    end

    def get_performance_gap(importance, maturity)
      (importance.nil? ? 0 : importance.to_i)-(maturity.nil? ? 0 : maturity.to_i)
    end

	def subsection_sorting(subsections, survey_id)
        @sub_sections = Array.new
        subsections.each do |subsection|
          if subsection.questions.present?
            @sub_sections << subsection
          end
        end
        @sub_sections
      end


    def check_subsection_all_ans(subsection, survey_id)
      @sub_section_answered = true
      subsection.questions.each do |question|
        if !Response.find_by_survey_id_and_question_id(survey_id, question.id).present?
          @sub_section_answered = false
        end
      end
      @sub_section_answered
    end

  def priority_class(answer_priority)
    case answer_priority
    when 'must_do' then 'success'
    when 'should_do' then 'warning'
    when 'could_do' then 'danger'
    end
  end

  def priority_column(answer_priority)
    content_tag :div, content_tag(:p, answer_priority.to_s.humanize), class: "div-td td-priority #{priority_class(answer_priority)}"
  end
end
