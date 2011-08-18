namespace :db do
  namespace :test do
    task :prepare do
    end
  end

  task test_export: :environment do
    leads = Lead.status_is('Converted').limit(3)
    contacts = leads.map(&:contact)
    accounts = contacts.map(&:account)
    lead_comments = leads.map(&:comments)
    contact_comments = contacts.map(&:comments)
    account_comments = accounts.map(&:comments)
    lead_tasks = leads.map(&:tasks)
    contact_tasks = contacts.map(&:tasks)
    account_tasks = accounts.map(&:tasks)

    File.open('users.csv', 'w+') do |file|
      fields = [
        'email'
      ]

      file.write fields.join(',') + "\n"

      users = User.where(email: 'mattbeedle@googlemail.com')

      file.write users.map { |u| u.deliminated(',', fields) }.join("\n")
    end

    File.open('leads.csv', 'w+') do |file|
      fields = [
        'phone', 'job_title', 'fax', 'address', 'postal_code', 'salutation',
        'country', 'company', 'title', 'last_name', 'city', 'first_name',
        'contact_id'
      ]

      file.write fields.join(',') + "\n"

      file.write leads.map { |l| l.deliminated(',', fields) }.join("\n")
    end

    File.open('contacts.csv', 'w+') do |file|
      fields = [
        'salutation', 'title', 'first_name', 'last_name', 'account_id',
        'email', 'mobile', 'phone', 'address', 'city', 'postal_code', 'fax',
        'job_title'
      ]

      file.write fields.join(',') + "\n"

      file.write contacts.map { |c| c.deliminated(',', fields) }.join("\n")
    end

    File.open('accounts.csv', 'w+') do |file|
      fields = [
        'name', 'billing_address', 'phone', 'website', 'email', 'fax'
      ]

      file.write fields.join(',') + "\n"

      file.write accounts.map { |c| c.deliminated(',', fields) }.join("\n")
    end
  end

  desc 'Import leads csv'
  task :import_leads_csv => :environment do
    user = User.first(:email => /beedle/i)
    data = {}
    File.open('leads.csv', 'r').each_with_index do |line, index|
      next if index == 0
      details = line.split(',')
      company, contact_names, phone, email, url = details[0], details[1], details[2], details[3], details[4]
      if data[company].blank?
        data[company] = { :contact_names => [contact_names], :phones => [phone], :emails => [email],
          :urls => [url] }
      else
        data[company][:contact_names] << contact_names
        data[company][:phones] << phone
        data[company][:emails] << email
        data[company][:urls] << url
      end
    end

    data.each do |key, attributes|

      contact_names = attributes.delete(:contact_names)
      contact_names.each_with_index do |name, index|
        names = name.strip.gsub(/\"/, '').split(/\s/)
        I18n.in_locale(:de) do
          lead = user.leads.build :company => key, :salutation => names.first,
            :first_name => names[1], :last_name => names.last || 'Unknown',
            :do_not_log => true, :do_not_notify => true, :do_not_index => true,
            :phone => attributes[:phones].shift, :email => attributes[:emails].shift,
            :notes => attributes[:urls].delete_if { |url|
              url.match(/@/)
            }.map { |url| "<a href='#{url}' target='_blank'>#{url}</a>" }.join('<br/>'),
            :source => 'Other'
          next if Lead.first(:email => /#{lead.email}/i)

          ids = Account.only(:id, :name).map do |account|
            [account.id, lead.company.levenshtein_similar(account.name)]
          end.select { |similarity| similarity.last > 0.9 }.map(&:first)

          unless ids.blank?
            puts "Skipped lead #{lead.name} (#{lead.company})"
            puts "Similar accounts: #{Account.all(:_id => ids).map(&:name).join(', ')}"
            next
          end

          if lead.similar(0.85).any?
            puts "Skipped lead #{lead.name}, (#{lead.company})"
            puts "Similar leads: #{Lead.all(:_id => ids).map(&:company).join(', ')}"
            next
          end
          if lead.save
            puts "Created lead #{lead.name} (#{lead.company})"
            Sunspot.index lead
          else
            puts names.inspect
            puts names.first
            throw lead
          end
        end
      end
    end
  end

  desc "Convert MongoDB data to Postgres"
  task :migrate_data => :environment do
    Dir[ File.join(Rails.root, "db", "migrate", "*.rb") ].sort.each { |file| require file }

    puts "Migrating the MongoDB data to PostgreSQL"
    [ MigrateAccounts, MigrateActivities, MigrateAttachments, MigrateComments,
      MigrateCompanies, MigrateContacts, MigrateDomains, MigrateLeads, MigrateTasks ].each do |migration|
      migration.up
    end
  end

  desc "Convert MongoDB users to Postgres"
  task :migrate_users => :environment do
    Dir[ File.join(Rails.root, "db", "migrate", "*.rb") ].sort.each { |file| require file }

    puts "Migrating the users"
    MigrateUsers.up
  end

  desc "Re-relate the Postgre relations"
  task :re_relate => :environment do
    Dir[ File.join(Rails.root, "db", "migrate", "*.rb") ].sort.each { |file| require file }

    puts "Hooking up the Postgre Relations"
    [ AssociateAccounts, AssociateActivities, AssociateAttachments, AssociateComments,
      AssociateContacts, AssociateLeads, AssociateTasks, AssociateUsers ].each do |migration|
      migration.up
    end
  end

  desc "Fix has constants"
  task :fix_has_constants => :environment do
    Dir[ File.join(Rails.root, "db", "migrate", "*.rb") ].sort.each { |file| require file }

    puts "Fixing has constants"
    FixHasConstants.up
  end

  desc "Fix Attachments"
  task :fix_attachments => :environment do
    Dir[ File.join(Rails.root, "db", "migrate", "*.rb") ].sort.each { |file| require file }

    puts 'Fixing attachments'
    FixAttachments.up
  end

  desc 'Migrate opportunity stages to has_constant'
  task :migrate_opportunity_stages => :environment do
    Opportunity.all.each do |o|
      o.stage = 'New'
      o.save!
    end
  end
end
