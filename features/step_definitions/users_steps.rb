Given /^I have an invitation$/ do
  user = User.make(:annika)
  user.confirm!
  store_model('user', 'annika', user)
  invitation = Invitation.make :email => 'werner@1000jobboersen.de', :inviter => user
  store_model('invitation', 'invitation', invitation)
end

Given /^I am registered and logged in as annika$/ do
  visit new_user_path
  fill_in_registration_form(:email => 'annika.fleischer@1000jobboersen.de')
  click_button 'user_submit'
  visit user_confirmation_path(:confirmation_token =>
                               User.last.confirmation_token)
  store_model('user', 'annika', User.last)
end

Given /^I am registered and logged in as Carsten Werner$/ do
  user = User.make(:carsten_werner)
  user.confirm!
  store_model('user', 'carsten_werner', user)
  visit new_user_session_path
  fill_in 'user_email', :with => 'carsten.werner@1000jobboersen.de'
  fill_in 'user_password', :with => 'password'
  click_button 'user_submit'
end

Given /^I have a Freelancer invitation$/ do
  user = User.make(:annika)
  user.confirm!
  store_model('user', 'annika', user)
  invitation = Invitation.make :email => 'werner@1000jobboersen.de', :inviter => user, :role => 'Freelancer'
  store_model('invitation', 'invitation', invitation)
end

Given /^I am logged in as #{capture_model}$/ do |m|
  model = model!(m)
  visit new_user_session_path
  fill_in 'user_email', :with => model.email
  fill_in 'user_password', :with => 'password'
  click_button 'user_submit'
end

Given /^#{capture_model} is confirmed$/ do |m|
  model!(m).confirm!
end

Given /^I am registered and logged in as Matt$/ do
  matt = User.make(:matt)
  matt.confirm!
  store_model('user', 'matt', User.first)
  visit new_user_session_path
  fill_in 'user_email', :with => matt.email
  fill_in 'user_password', :with => 'password'
  click_button 'user_submit'
  matt.update_attributes :role => 'Administrator'
end