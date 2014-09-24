module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def select_with_client_side_validations(method, choices, options = {}, html_options = {})
    apply_client_side_validators(method, html_options)
    select_without_client_side_validations(method, choices, options, html_options)
  end

  def show_question_number(question)
    position = question.position
    count = 0
    @all_sections.limit(question.section_id.to_i - 1).each_with_index do |section, index|
      count = count + @section_questions_total[index].question_total.to_i
    end
    position > count ? (position - count) : position
  end

end
