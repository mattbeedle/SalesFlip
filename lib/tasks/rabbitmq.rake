namespace :rabbitmq do

  desc "Run the RabbitMQ subscriber for opportunities"
  task :opportunities => :environment do
    Messaging::Opportunities.new.subscribe
  end
end
