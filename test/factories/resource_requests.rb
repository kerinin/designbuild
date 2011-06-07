# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :resource_request do |f|
  f.duration 1.5
  
  f.project {|p| p.association(:project)}
  f.resources {|p| [p.association(:resource)]}
end
