source 'https://rubygems.org'

gem 'rails', '3.2.2'
gem 'pg'
gem 'devise'
#gem 'oa-oauth', :require => 'omniauth/oauth'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
#gem 'omniauth-google'
gem 'omniauth-google-oauth2'
gem 'oauth2'
#gem 'omniauth-google-apps'
#gem "oa-openid"
#gem 'omniauth-openid'
gem 'uuidtools'
gem 'will_paginate', '~> 3.0'
gem 'bootstrap-will_paginate'
gem 'jquery-rails'
gem "client_side_validations", '~>3.1.4'
gem 'settingslogic'
gem 'therubyracer'
gem 'uglifier', '>= 1.0.3'
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
gem 'rubyzip'
gem 'newrelic_rpm'
#google charts
gem "googlecharts"
gem "gchartrb"
#bootstrap rails gem
gem "twitter-bootstrap-rails"

group :development do
gem "annotate", "~>2.4.1.beta1"
gem "rails_best_practices"
gem 'wkhtmltopdf-binary'
end

#wkhtmltopdf for test, stage and production enviornments
group :test, :staging, :production do 
	gem "wkhtmltopdf-heroku"
end	
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem "twitter-bootstrap-rails"
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

