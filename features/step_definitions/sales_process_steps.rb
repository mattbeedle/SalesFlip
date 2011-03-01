def t(*args)
  I18n.t(*args)
end

Given /^I am signed in as a sales person$/ do
  user = User.make
  user.confirm!
  store_model('user', 'me', user)
  visit new_user_session_path
  fill_in 'user_email', :with => user.email
  fill_in 'user_password', :with => 'password'
  click_link_or_button 'user_submit'
end

Given /^I am signed in as a service person$/ do
  user = User.make(role: 'Service Person')
  user.confirm!
  store_model('user', 'me', user)
  visit new_user_session_path
  fill_in 'user_email', :with => user.email
  fill_in 'user_password', :with => 'password'
  click_link_or_button 'user_submit'
end

Given /^there is a new unassigned lead$/ do
  store_model('lead', 'lead', Lead.make(user: model('user')))
end

Given /^there is a new lead assigned to me$/ do
  lead = Lead.make(user: model('user'), assignee: model('user'))
  store_model('lead', 'lead', lead)
end

Given /^I have a lead with the status "([^"]*)"$/ do |status|
  lead = Lead.make(
    user: model('me'),
    assignee: model('me'),
    status: status
  )
  store_model('lead', 'lead', lead)
end

Then /^I should see no leads$/ do
  page.should have_no_css("tr.item")
end

Then /^I should see the lead$/ do
  within "#main" do
    page.should have_content model('lead').full_name
  end
end

When /^I ask for my next lead$/ do
  click_link_or_button t(:next_lead)
end

Given /^I have called the customer$/ do
  click_link_or_button t(:already_contacted?)
end

When /^I say the customer requested infomail$/ do
  click_link_or_button t(:customer_requested_infomail)
end

When /^I schedule an infomail followup task$/ do
  within "#schedule_infomail_followup" do
    fill_in t("simple_form.labels.task.name"), :with => "Infomail Followup"
    click_button t(:schedule)
  end
end

Then /^the lead should have the status "([^"]*)"$/ do |status|
  model('lead').status.should == status
end

Then /^it should have an infomail followup task$/ do
  task = model('lead').tasks.last
  task.name.should == "Infomail Followup"
  task.category.should == "Follow-up"
end

# rescheduling a call

When /^I say the customer wants to be called back$/ do
  click_link_or_button t(:customer_wants_to_be_called_back)
end

When /^I reschedule the call$/ do
  within "#call_back" do
    click_link_or_button t(:schedule)
  end
end

Then /^it should have a task for the rescheduled call$/ do
  task = model('lead').tasks.last
  task.name.should == "Rescheduled"
  task.category.should == "Call"
end

# rejecting a lead

When /^I say the customer doesn't want to be called back$/ do
  click_link t(:customer_doesnt_want_to_be_contacted)
end

# requesting an offer

When /^I say the customer requested an offer$/ do
  click_link t(:customer_requested_offer)
end

When /^I schedule an email task to send the offer$/ do
  within "#offer_requested" do
    click_button t(:schedule)
  end
end

Then /^it should have an email task to send the offer$/ do
  task = model('lead').tasks.last
  task.name.should == "Send Offer"
  task.category.should == "Email"
end
