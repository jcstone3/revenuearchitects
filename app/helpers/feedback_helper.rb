module FeedbackHelper
  def feedback_init(options = {})
    options = {
      "position" => "null"
    }.merge(options.stringify_keys)

    options['position'] = "'#{options['position']}'" unless options['position'].blank? || options['position'] == 'null'
     "<script type='text/javascript'>$(document).ready(function() { $('.feedback_link').feedback({tabPosition: #{options["position"]}}); });</script>"
  end

  def feedback_includes()
    stylesheet_link_tag('feedback') +
    javascript_include_tag('jquery.feedback.js')
  end

  def feedback_tab(options = {})
    feedback_init({'position' => 'left'}.merge(options.stringify_keys))
  end


  def feedback_link(text, options = {})
    link_to text, '#', :class => "feedback_link"
  end
end
