# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :resource_request do |f|
  f.urgent false
  f.first_date "2011-06-06"
  f.deadline "2011-06-06"
  f.duration 1.5
  f.allocated 1.5
  f.remaining 1.5
end
