Given /^my locale is "([^"]*)"$/ do |locale|
  I18n.locale = locale
end

# Allows translation within cucumber features.
#
#   When I follow t(self_generated)
#     => When I follow "#{t(:self_generated)}"
#
Given(
/ ^
  (.*)              # I should see
  (t\(([^)]+)\))    # t(self_generated)
  (.*)              # within "#main"
  $
/x) do |first, _, key, last|
  Given %Q[#{first}"#{t(key)}"#{last}]
end
