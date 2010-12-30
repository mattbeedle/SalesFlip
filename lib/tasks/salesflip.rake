namespace :salesflip do
  desc 'Setup new project'
  task :setup => :environment do
    c = Company.create! :name => 'Test Company'
    user = c.users.create! :email => 'test@test.com', :password => 'password',
      :password_confirmation => 'password'
    user.confirm!
  end

  desc 'Clear old invalid data'
  task :cleanup => :environment do
    Task.all.each do |task|
      task.asset rescue task.destroy
    end
    Activity.all.each do |activity|
      activity.subject rescue activity.destroy
    end

  end
end
