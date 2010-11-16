# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :contract do |f|
  f.name {Forgery::DesignBuild.contract_name}
  f.bid {Forgery::Monetary.money :min => 1000, :max => 100000}
  
  f.project {|p| p.association(:project)}
end
