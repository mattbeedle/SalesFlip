Given /^#{capture_model} has been deleted$/ do |item|
  m = model!(item)
  m.destroy
end

When /^I click the delete button for the account$/ do
  click_link_or_button "delete_account_#{Account.first.id}"
end

When /^I click the delete button for the contact$/ do
  click_link_or_button "delete_contact_#{Contact.first.id}"
end
