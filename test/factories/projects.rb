# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :project do |f|
  f.name {Forgery::DesignBuild.project_name}
  f.labor_percent_retainage 0
  f.material_percent_retainage 0
end
