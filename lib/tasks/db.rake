namespace :db do
  
  desc 'Import leads csv'
  task :import_leads_csv => :environment do
    user = User.where(:email => /beedle/i).first
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
            :phone => attributes[:phones].shift, :email => attributes[:emails].shift,
            :notes => attributes[:urls].delete_if { |url|
              url.match(/@/)
            }.map { |url| "<a href='#{url}' target='_blank'>#{url}</a>" }.join('<br/>'),
            :source => 'Other'
          next if Lead.where(:email => /#{lead.email}/i).first

          ids = Account.only(:id, :name).map do |account|
            [account.id, lead.company.levenshtein_similar(account.name)]
          end.select { |similarity| similarity.last > 0.9 }.map(&:first)

          unless ids.blank?
            puts "Skipped lead #{lead.name} (#{lead.company})"
            puts "Similar accounts: #{Account.where(:_id.in => ids).map(&:name).join(', ')}"
            next
          end

          ids = Lead.only(:id, :company).map do |l|
            [l.id, lead.company.levenshtein_similar(l.company)]
          end.select { |similarity| similarity.last > 0.9 }.map(&:first)

          unless ids.blank?
            puts "Skipped lead #{lead.name}, (#{lead.company})"
            puts "Similar leads: #{Lead.where(:_id.in => ids).map(&:company).join(', ')}"
            next
          end
          if lead.save
            puts "Created lead #{lead.name} (#{lead.company})"
          else
            puts names.inspect
            puts names.first
            throw lead
          end
        end
      end
    end
  end
end