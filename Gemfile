source 'http://rubygems.org'

gem 'rails', '3.0.1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3-ruby', :require => 'sqlite3'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'
gem 'rails3-generators', :group => :development
gem 'haml-rails'
gem 'jquery-rails'
gem 'compass', ">= 0.10.6"
#gem 'authlogic', '>= 2.1.6'
gem 'devise'
gem "aws-s3" #, :lib => "aws/s3"
gem 'paperclip', ">= 2.3.5"
gem "friendly_id", "~> 3.1"
# gem "memcached"
# gem "acts_as_list", :git => 'git://github.com/rails/acts_as_list.git'
#gem "ancestry", '1.2.3'  #using fork w/ .joins() fixes from git://github.com/raelik/ancestry.git
                          # issue: https://github.com/stefankroes/ancestry/issuesearch?state=open&q=joins#issue/35
gem "abstract"
# gem 'inherited_resources', '1.1.2'
gem 'rails3-jquery-autocomplete'
gem 'paper_trail'
gem 'state_machine'
#gem 'pg'
gem 'will_paginate', '>=3.0.pre'
gem 'gcal4ruby'
gem 'delayed_job'
gem 'hirefireapp'
gem 'RedCloth'

group :test, :development do
  gem "yaml_db"
  gem "ruby-prof"
  gem "shoulda"
  gem "rspec-rails", "2.0.0.beta.12"
  gem 'factory_girl_rails'
  gem 'forgery'
  gem 'database_cleaner'
end

group :production do
  gem 'dalli'
  gem 'exception_notification', :require => 'exception_notifier'
end


# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
