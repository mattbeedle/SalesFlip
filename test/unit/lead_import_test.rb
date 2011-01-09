require 'test_helper'

class LeadImportTest < ActiveSupport::TestCase
  context 'Class' do
    should_have_key :deliminator, :unimported
    should_belong_to :user, :assignee
    should_have_constant :states
    should_have_uploader :file
    should_validate_presence_of :user
  end

  context 'Instance' do
    setup do
      @user = User.make
      FakeWeb.allow_net_connect = true
    end

    context 'when importing a valid CSV file' do
      context 'without an assignee' do
        setup do
          @import = LeadImport.create!(:user => @user,
                                       :file => File.open('test/support/leads.csv'),
                                       :deliminator => ',')
          @import.import
        end

        should 'know the number of lines in the file' do
          assert_equal 4, @import.lines.count
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

        should 'default state to "pending"' do
          assert_equal 'pending', LeadImport.new.state
        end

        should 'have state of "completed" after completing' do
          assert_equal 'completed', @import.reload.state
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
          @search = Lead.search { keywords '' }
          @search.stubs(:results).returns([Lead.where(:last_name => 'Smith').first])
          Lead.stubs(:search).returns(@search)
          @import = LeadImport.create!(:user => @user,
                                       :file => File.open('test/support/duplicate_lead.csv'),
                                       :deliminator => ',')
          @import.import
          assert_equal 1, @import.unimported.length
        end
      end

      context 'with an assignee' do
        setup do
          @assignee = User.make
          @import = LeadImport.new(:user => @user,
                                   :file => File.open('test/support/leads.csv'),
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
