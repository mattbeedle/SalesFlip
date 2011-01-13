require Rails.root + 'test/blueprints'

DataMapper.auto_migrate!

puts "Creating users"
matt = User.make(:matt)
sales_person = User.make

users = 52.times.map { User.make(company: sales_person.company) }

puts "Creating leads"
50.times do
  Lead.make(
    user: sales_person,
    permission: 'Private'
  )
end

50.times do
  Lead.make(
    user: users.sample,
    permission: 'Public'
  )
end

100.times do
  Lead.make(
    user: users.sample,
    assignee: sales_person
  )
end

100.times do
  Lead.make(
    user: users.sample,
    permission: 'Shared',
    permitted_users: [sales_person]
  )
end

puts "", "", "", "="*80
puts "  %20s    %s" % ["admin", matt.email]
puts "  %20s    %s" % ["sales person", sales_person.email]
puts "="*80
