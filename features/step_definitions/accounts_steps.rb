Given /^careermee is shared with annika$/ do
  c = Account.where(:name => /CareerMee/i).first
  a = User.where(:email => 'annika.fleischer@1000jobboersen.de').first
  c.update_attributes :permission => 'Shared', :permitted_user_ids => [a.id]
end

Given /^I follow the edit link for the account$/ do
  click_link "edit_account_#{Account.last.id}"
end

Given /^I click the delete button for the task$/ do
  click_button "delete_task_#{Task.first.id}"
end

When /^I click the delete button for the comment$/ do
  click_button "delete_comment_#{Comment.first.id}"
end

Then /^#{capture_model} should have sub account: #{capture_model}$/ do |parent, sub|
  parent = model!(parent)
  sub = model!(sub)
  assert parent.children.include?(sub)
end

When /^I add a contact$/ do
  click "Add Contact"
  fill_in 'First Name', :with => 'Matt'
  fill_in 'Last Name', :with => 'Beedle'
  click_button 'contact_submit'
end

When /^I add a task$/ do
  click "Add Task"
  click "preset_date"
  fill_in 'Subject', :with => 'Make these features pass'
  select 'Follow-up', :from => 'Category'
  select 'Today', :from => 'Due at'
  click_button 'task_submit'
end

When /^I add a comment$/ do
  fill_in 'comment_text', :with => 'This is pretty cool'
  click_button 'comment_submit'
end
