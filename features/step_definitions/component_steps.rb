Given /^the following components:$/ do |components|
  Component.create!(components.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) component$/ do |pos|
  visit components_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following components:$/ do |expected_components_table|
  expected_components_table.diff!(tableish('table tr', 'td,th'))
end
