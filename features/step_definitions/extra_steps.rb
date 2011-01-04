Given /^all delayed jobs have finished$/ do
  Delayed::Worker.new.work_off
end
