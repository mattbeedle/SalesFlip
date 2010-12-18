Then /^#{capture_model} should have (\d+) assigned (\w+)$/ do |name, size, association|
  model!(name).send("assigned_#{association}").size.should == size.to_i
end
Then /^a view activity should have been created for opportunity with title "([^\"]*)"$/ do |title|
  assert Activity.first(:conditions => { :action => Activity.actions.index('Viewed') }).
    subject.title == title
end