# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :component do |f|
  f.name {Forgery::DesignBuild.component_name}
  
  f.project {|p| p.association(:project)}
end
