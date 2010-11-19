# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :markup do |f|
  f.name {Forgery::DesignBuild.markup_name}
  f.percent {rand(20)}
end
