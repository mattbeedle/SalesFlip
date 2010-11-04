Given /^florian is shared with annika$/ do
  u = User.first(:conditions => { :email => 'annika.fleischer@1000jobboersen.de' })
  c = Contact.first(:conditions => { :first_name => 'Florian' })
  c.update_attributes :permission => 'Shared', :permitted_user_ids => [u.id]
end

Given /^I follow the edit link for the contact$/ do
  click_link "edit_contact_#{Contact.last.id}"
end

Given /^the contact is shared with the other user$/ do
  contact = model!('contact')
  user = model!('user')
  contact.update_attributes :permission => 'Shared', :permitted_user_ids => [user.id]
end

Then /^#{capture_model} should have a contact with first_name: "(.+)"$/ do |target, first_name|
  assert model!(target).contacts.find(:first, :conditions => { :first_name => first_name })
end

Then /^the newly created contact should have an opportunity$/ do
  assert_equal 1, Contact.first.opportunities.count
end

Then /^the #{capture_model} should belong to #{capture_model}$/ do |contact, user|
  contact = model!(contact)
  user = model!(user)
  assert user.contacts.include?(contact)
end