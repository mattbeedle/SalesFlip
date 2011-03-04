Given /^I follow the edit link for the account$/ do
  click_link_or_button "edit_account_#{Account.last.id}"
end

Given /^I click the delete button for the task$/ do
  click_link_or_button "delete_task_#{Task.first.id}"
end

When /^I click the delete button for the comment$/ do
  click_link_or_button "delete_comment_#{Comment.first.id}"
end

Then /^#{capture_model} should have sub account: #{capture_model}$/ do |parent, sub|
  parent = model!(parent)
  sub = model!(sub)
  assert parent.children.include?(sub)
end

When /^I add a contact$/ do
  click_link_or_button 'Add Contact'
  fill_in 'First Name', :with => 'Matt'
  fill_in 'Last Name', :with => 'Beedle'
  click_link_or_button 'contact_submit'
end

When /^I add a task$/ do
  click_link_or_button 'Add Task'
  click_link_or_button 'preset_date'
  fill_in 'Subject', :with => 'Make these features pass'
  select 'Follow-up', :from => 'Category'
  select 'Today', :from => 'Due at'
  click_link_or_button 'task_submit'
end

When /^I add a comment$/ do
  fill_in 'comment_text', :with => 'This is pretty cool'
  click_link_or_button 'comment_submit'
end
