require 'test_helper'

class LeadImportTest < ActiveSupport::TestCase
  context 'Class' do
    should_have_key :deliminator, :unimported, :source
    should_belong_to :user, :assignee
    should_have_constant :states, :sources
    should_have_uploader :file
    should_require_key :user
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
                                       :deliminator => ';')
        end

        should 'know the number of lines in the file' do
          @import.import
          assert_equal 4, @import.lines.count
        end

        should 'count imported leads' do
          @import.import
          assert_equal 3, @import.imported.length
        end

        should 'store imported leads' do
          @import.import
          assert @import.imported.include?(Lead.first)
        end

        should 'import all the leads' do
          @import.import
          assert_equal 3, Lead.count
        end

        should 'set all leads source to "Imported"' do
          @import.import
          Lead.all.each do |lead|
            assert_equal 'Imported', lead.source
          end
        end

        should 'set all leads to different source if one is specified' do
          @import.update_attributes :source => 'Campaign'
          @import.import
          assert Lead.all.all? { |l| l.source == 'Campaign' }
        end

        should 'default state to "pending"' do
          @import.import
          assert_equal 'pending', LeadImport.new.state
        end

        should 'have state of "completed" after completing' do
          @import.import
          assert_equal 'completed', @import.reload.state
        end

        should 'get the lead details correct' do
          @import.import
          assert Lead.where(:first_name => 'Torsten', :last_name => 'Hehenberger',
                            :company_size => Lead.company_sizes.index('6-10'),
                            :phone => '0351 4943-0', :company => 'DATEV eG'
                           ).first
        end
      end

      context 'with an assignee' do
        setup do
          @assignee = User.make
          @import = LeadImport.new(:user => @user,
                                   :file => File.open('test/support/leads.csv'),
                                   :deliminator => ';', :assignee => @assignee)
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
