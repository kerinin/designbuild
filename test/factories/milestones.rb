# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :milestone do |f|
  f.name {Forgery::DesignBuild.deadline_name}
  f.date {Forgery::Date.date :future => true, :max_delta => 180}
  
  f.project {|p| p.association(:project)}
  f.task {|p| p.association(:task)}
end