# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :user do |f|
  f.email { Forgery::Internet.email_address }
end
