# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :invoice do |f|
  f.project {|p| p.association(:project)}
end
