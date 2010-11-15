Given /^the following components:$/ do |components|
  Component.delete_all
  Component.create!(components.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) component$/ do |pos|
  within("table tr.component:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following components:$/ do |expected_components_table|
  expected_components_table.diff!(tableish('table tr.component', 'td,th'))
end
