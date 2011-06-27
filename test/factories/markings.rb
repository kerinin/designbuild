# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :marking do |f|
  f.markup {|p| p.association(:markup)}
  f.markupable {|p| p.association(:project)}
end
