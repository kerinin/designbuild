# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :supplier do |f|
  f.name { Forgery::DesignBuild.supplier_name }
end
