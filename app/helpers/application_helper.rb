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
end
