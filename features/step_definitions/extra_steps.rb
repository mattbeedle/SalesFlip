Given /^all delayed jobs have finished$/ do
  Resque.run!
end
