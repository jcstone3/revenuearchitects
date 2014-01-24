source 'http://rubygems.org'

ruby "1.9.3"
gem 'rails', '3.2.11'
gem 'pg'
gem "devise", "~> 2.1.3"
#gem 'oa-oauth', :require => 'omniauth/oauth'

gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
#gem 'omniauth-google'
gem 'omniauth-google-oauth2', '~> 0.2.2'
gem 'oauth2'
#gem 'omniauth-google-apps'
#gem "oa-openid"
#gem 'omniauth-openid'
gem 'uuidtools'
gem 'will_paginate', '~> 3.0'
gem 'bootstrap-will_paginate', '0.0.9'
gem 'jquery-rails', '~> 2.0.2'

gem 'simple_form', "~> 2.0.1"

gem "acts_as_ordered", "~> 0.0.1.alpha"
gem "client_side_validations", '~>3.1.4'
gem 'settingslogic'
#gem 'therubyracer', '~> 0.9.2', :platforms => :ruby, :require => 'v8'
gem 'execjs', '1.4.0'
gem 'uglifier', '1.3.0'
#Gems used for pdf and xls generation
gem 'pdfkit'
gem "spreadsheet", "0.6.5.8"
gem "to_xls", :git => "https://github.com/dblock/to_xls.git", :branch => "to-xls-on-models"
# Gem used for creating sample data
gem 'populator3'
gem 'highline'
gem "random_data"
gem 'database_cleaner'
gem 'faker'
gem 'rubyXL', '1.2.5'
gem 'nokogiri'
gem 'rubyzip', '0.9.9'
#google charts
gem "googlecharts"
#gem "gchartrb"
gem "google_visualr", ">= 2.1"
#gem "google_charts"
#bootstrap rails gem
gem "less-rails", '2.1.8'
gem 'twitter-bootstrap-rails', '2.2.0'
gem 'taps'
gem 'exception_notification', :git => "git://github.com/rails/exception_notification.git",
        :require => "exception_notifier"
gem "permanent_records", "~> 2.1.2"
gem "acts_as_list", "~> 0.1.6"
#gem "ordered-active-record", "~> 0.9.7"

group :development do
gem "annotate", "~>2.4.1.beta1"
gem "rails_best_practices"
gem 'wkhtmltopdf-binary'
gem 'unicorn'
end

#wkhtmltopdf for test, stage and production enviornments
group :test, :staging, :production do
	gem "wkhtmltopdf-heroku"
	gem 'newrelic_rpm'
end
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails', '3.2.2'
  # gem "less-rails"
  # gem "twitter-bootstrap-rails"
end



# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

