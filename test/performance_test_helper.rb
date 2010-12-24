# START : HAX HAX HAX
# Load Rails environment in 'test' mode
#ENV["RAILS_ENV"] = "test"
#require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
# Re-establish db connection for 'performance' mode
silence_warnings { Rails.env = 'performance' } #ENV["RAILS_ENV"] = "performance" }
ActiveRecord::Base.establish_connection
# STOP : HAX HAX HAX

#require_dependency 'application'

#require 'test/unit'
#require 'active_support/test_case'
#require 'action_controller/test_case'
#require 'action_controller/integration'

#require 'performance_test_help'
