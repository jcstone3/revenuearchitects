# ClientSideValidations Initializer

require 'client_side_validations/simple_form' if defined?(::SimpleForm)
require 'client_side_validations/formtastic'  if defined?(::Formtastic)

# Uncomment the following block if you want each input field to have the validation messages attached.
# ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
#   unless html_tag =~ /^<label/
#     %{<div class="field_with_errors">#{html_tag}<label for="#{instance.send(:tag_id)}" class="message">#{instance.error_message.first}</label></div>}.html_safe
#   else
#     %{<div class="field_with_errors">#{html_tag}</div>}.html_safe
#   end
# end

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  unless html_tag =~ /^<label/
    %{<div class="field_with_errors">#{html_tag}<label for="#{instance.send(:tag_id)}" class="message">#{instance.error_message.first}</label></div>}.html_safe
  else
    %{<div class="field_with_errors">#{html_tag}</div>}.html_safe
  end

end

def select_with_client_side_validations(method, choices, options = {}, html_options = {})
  apply_client_side_validators(method, html_options)
  select_without_client_side_validations(method, choices, options, html_options)
end