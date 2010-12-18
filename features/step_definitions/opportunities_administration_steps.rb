Given /^there is only 1 opportunity stage$/ do
  OpportunityStage.delete_all
  OpportunityStage.make :company => User.first.company
end

Then /the opportunity stage should have been deleted$/ do
  assert_equal 1, OpportunityStage.deleted.count
end
