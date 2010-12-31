namespace(:sunspot) do
  desc 'Start solr'
  task :start => :environment do
    solr_config = YAML::load(File.read(File.join(Rails.root, '/config/mongoid.yml')))
    system "sunspot-solr start -p #{solr_config['production']['port']} -d solr/data/#{Rails.env} -s solr --pid-dir=tmp/pids -l FINE --log-file=log/sunspot-solr-#{Rails.env}.log"
  end

  desc 'Stop solr'
  task :stop => :environment do
    solr_config = YAML::load(File.read(File.join(Rails.root, '/config/mongoid.yml')))
    system "sunspot-solr stop -p #{solr_config['production']['port']} -d solr/data/#{Rails.env} -s solr --pid-dir=tmp/pids -l FINE --log-file=log/sunspot-solr-#{Rails.env}.log"
  end
end
