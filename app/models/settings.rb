  class Settings < Settingslogic
    #This is alternative configuration
    #source "# { Rails. root }/config/application.yml"
    source "config/application.yml"
    namespace Rails.env
  end
