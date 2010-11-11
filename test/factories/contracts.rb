# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :contract do |f|
  f.contractor "MyString"
  f.bid 1.5
end
