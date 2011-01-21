Then /^I should see "([^"]*)" in the source$/ do |val|
  assert page.body.match(/#{val}/)
end

Given /^I should not see "([^"]*)" in the source$/ do |val|
  assert !page.body.match(/#{val}/)
end

And "I debug" do
  require 'ruby-debug'; Debugger.start; Debugger.settings[:autoeval] = 1; Debugger.settings[:autolist] = 1; debugger
  1
end
