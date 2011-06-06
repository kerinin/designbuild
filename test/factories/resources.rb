# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :resource do |f|
  f.name {Forgery::DesignBuild.resource_name}
end
