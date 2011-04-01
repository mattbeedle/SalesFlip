Given /^I follow the edit link for the contact$/ do
  click_link_or_button "edit_contact_#{Contact.last.id}"
end

Then /^#{capture_model} should have a contact with first_name: "(.+)"$/ do |target, first_name|
  assert model!(target).contacts.all(:first_name => first_name).first
end

Then /^the newly created contact should have an opportunity$/ do
  assert_equal 1, Contact.first.opportunities.count
end

Then /^the #{capture_model} should belong to #{capture_model}$/ do |contact, user|
  contact = model!(contact)
  user = model!(user)
  assert user.contacts.include?(contact)
end
