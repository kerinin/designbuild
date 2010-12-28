# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :date_point do |f|
  f.date {Forgery::Date.date :future => false, :max_delta => 180}
  f.value {rand(100)}
  f.series 'estimated_cost'
end
