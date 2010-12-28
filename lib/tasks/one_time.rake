require 'csv'

namespace(:one_time) do
  desc "Import Mandy's leads"
  task :import_mandys_leads => :environment do
    CSV.open('doc/mandys_leads.csv', 'r', '|') do |row|
      user = User.find_by_email('mandy.cash@1000jobboersen.de')
      lead = user.leads.build :assignee => user, :do_not_log => true, :do_not_notify => true
      %w(salutation first_name last_name company phone email).each_with_index do |key, index|
        lead.send("#{key}=", row[index] ? row[index].strip : nil)
      end
      lead.save!
    end
  end

  desc "Index all leads, contacts and accounts"
  task :index_everything => :environment do
    Account.all.each(&:index!)
    Contact.all.each(&:index!)
    Lead.all.each(&:index!)
  end

  desc 'Add identifiers to all accounts, leads and contacts'
  task :add_identifiers => :environment do
    Account.all(:identifier => nil).each do |account|
      account.update :do_not_geocode => true, :identifier => Identifier.next_account,
        :do_not_log => true
    end
    Contact.all(:identifier => nil).each do |contact|
      contact.update :do_not_geocode => true, :identifier => Identifier.next_contact,
        :do_not_log => true
    end
    Lead.all(:identifier => nil).each do |lead|
      lead.update :do_not_geocode => true, :identifier => Identifier.next_lead,
        :do_not_notify => true, :do_not_log => true
    end
  end

  desc 'Update old style lead-contact relationship, to new style contact has_many leads'
  task :switch_contact_leads_to_has_many => :environment do
    Contact.all(:lead_id => { '$ne' => nil }).each do |contact|
      lead = Lead.first(:id => contact.lead_id)
      lead.update :contact_id => contact.id, :do_not_log => true
    end
  end

  desc 'Transfer abstract users'
  task :transfer_abstract_users => :environment do
    AbstractUser.all.each do |abstract_user|
      user = User.new(abstract_user.attributes)
      user.save(false)
      user.confirm!
    end
  end

  desc 'Add company scoping (1000JobBoersen.de)'
  task :add_company => :environment do
    c = Company.find_or_create_by_name('1000JobBoersen.de')
    User.all.each do |user|
      user.update :company_id => c.id
    end
  end

  desc 'Import helios dataset'
  task :helios_import => :environment do
    headings = ["title", "first_name", "last_name", "salutation", "job_title", "company",
      "department", "address", "postal_code", "city", "country", "phone", "email"]
    CSV.open('doc/helios.csv', 'r', '|') do |row|
      u = User.find_by_email('mattbeedle@googlemail.com')
      l = u.leads.build :source => 'Helios'
      headings.each_with_index do |heading,index|
        l.send("#{heading}=", row[index] ? row[index].strip : nil)
      end
      l.save!
    end
  end
  
  desc 'Import phonebook leads'
  task :import_phonebook_leads => :environment do
    require 'benchmark'
    headings = ['salutation', 'first_name', 'company', 'additional', 'street', 'address_number',
      'first_line_address', 'locality', 'D', 'postal_code', 'region', 'phone_type', 'phone_code',
      'phone_main', 'phone1', 'phone']
    File.open('doc/phone_book.txt', 'r').read.force_encoding('iso-8859-1').encode('utf-8').split("\r").each_with_index do |line, index|
      next if index == 0
      row = line.split("\t")
      next unless row[1].blank?
      u = User.where(:email => /beedle/i).first
      l = u.leads.build :source => 'Imported', :rating => 2, :do_not_log => true, :first_name => 'n/a',
        :last_name => 'n/a'
      
      headings.each_with_index do |heading, index|
        I18n.locale_around(:de) do
          l.send("#{heading}=", row[index] ? row[index].strip : nil) if l.respond_to?(heading)
        end
      end
      
      ids = Account.only(:id, :name).map do |account|
        [account.id, l.company.levenshtein_similar(account.name)]
      end.select { |similarity| similarity.last > 0.9 }.map(&:first)
      
      unless ids.blank?
        accounts = Account.where(:_id.in => ids)
        puts "skipped: #{l.company} (#{accounts.map(&:name).inspect})"
        next
      end
      
      ids = Lead.only(:id, :company).map do |lead|
        [lead.id, l.company.levenshtein_similar(lead.company)]
      end.select { |similarity| similarity.last > 0.9 }.map(&:first)
      
      unless ids.blank?
        leads = Lead.where(:_id.in => ids)
        puts "skipped: #{l.company} (#{leads.map(&:company).inspect})"
        next
      end
      
      begin
        l.save!
      rescue
        throw [l, row]
      end
    end
  end
end
