require 'test_helper'

class ImportTest < ActiveSupport::TestCase
  context 'Instance' do
    context 'when importing a valid CSV file' do
      context 'without an assignee' do
        setup do
          @user = User.make
          @import = Import.new(@user, Lead, File.open('test/support/leads.csv', 'r'),
                               :deliminator => ',')
          @import.import
        end

        should 'count imported leads' do
          assert_equal 3, @import.imported.length
        end

        should 'store imported leads' do
          assert @import.imported.include?(Lead.first)
        end

        should 'import all the leads' do
          assert_equal 3, Lead.count
        end

        should 'set all leads source to "Imported"' do
          Lead.all.each do |lead|
            assert_equal 'Imported', lead.source
          end
        end

        should 'get the lead details correct' do
          assert Lead.where(:salutation => Lead.salutations.index('Mrs'),
                            :first_name => 'Joe', :last_name => 'Smith',
                            :job_title => 'Personalreferentin',
                            :company => 'Just some company', :postal_code => '20354',
                            :city => 'Hamburg',
                            :address => 'Neuer Jungfernstieg 9-14', :country => 'Germany'
                           ).first
        end

        should 'generate a list of unimported items' do
          assert_equal 1, @import.unimported.length
        end
      end

      context 'with an assignee' do
        setup do
          @user = User.make
          @assignee = User.make
          @import = Import.new(@user, Lead, File.open('test/support/leads.csv', 'r'),
                               :deliminator => ',', :assignee => @assignee)
          @import.import
        end

        should 'set all of the leads assignee to the one specified' do
          Lead.all.each do |lead|
            assert_equal @assignee, lead.assignee
          end
        end

        should 'import all leads' do
          assert_equal 3, Lead.count
        end
      end
    end
  end
end
