# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :contract do |f|
  f.name {Forgery::DesignBuild.contract_name}
  
  f.project {|p| p.association(:project)}
end
