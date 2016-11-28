Given(/^I am on the landing page$/) do
  visit root_path
end

And(/^I click on "([^"]*)"$/) do |link|
  click_link_or_button link
end

Then(/^show me the page$/) do
  save_and_open_page
end

And(/^I fill in "([^"]*)" with "([^"]*)"$/) do |element, value|
  fill_in element, with: value
end