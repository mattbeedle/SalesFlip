Given /^there is only 1 opportunity stage$/ do
  OpportunityStage.destroy!
  OpportunityStage.make :company => User.first.company
end

Given /^#{capture_model} has no opportunity stages$/ do |arg1|
  model!(arg1).opportunity_stages.each &:destroy
end

Then /the opportunity stage should have been deleted$/ do
  assert_equal 1, OpportunityStage.deleted.count
end
