require 'test_helper.rb'

class LeadTest < ActiveSupport::TestCase
  context 'Class' do
    should_have_key :city, :postal_code, :country, :job_title, :department, :identifier
    should_have_constant :titles, :statuses, :sources, :salutations, :permissions
    should_act_as_paranoid
    should_be_trackable
    should_belong_to :user, :assignee, :contact
    should_have_many :comments, :tasks, :activities, :emails

    should 'know which fields may be exported' do
      Lead.properties.map(&:name).each do |field|
        field = field.to_s
        unless field == 'access' || field == 'permission' ||
          field == 'permitted_user_ids' || field == 'tracker_ids'
          assert_includes Lead.exportable_fields, field
        else
          refute_includes Lead.exportable_fields, field
        end
      end
    end

    context 'for_company' do
      setup do
        @lead = Lead.make(:erich)
        @lead2 = Lead.make(:markus)
      end

      should 'only return leads for the supplied company' do
        assert_equal [@lead], Lead.for_company(@lead.user.company).to_a
      end
    end

    context 'unassigned' do
      setup do
        @user = User.make(:annika)
        @assigned = Lead.make(:erich, :assignee => @user)
        @unassigned = Lead.make(:markus, :assignee => nil)
      end

      should 'return all unassigned leads' do
        assert_equal [@unassigned], Lead.unassigned
      end
    end

    context 'assigned_to' do
      setup do
        @user = User.make(:annika)
        @benny = User.make(:benny)
        @mine = Lead.make(:erich, :assignee => @user)
        @not_mine = Lead.make(:markus, :assignee => @benny)
      end

      should 'return all leads assigned to the supplied user' do
        assert_equal [@mine], Lead.assigned_to(@user.id)
        assert_equal [@not_mine], Lead.assigned_to(@benny.id)
      end
    end

    context 'tracked_by' do
      setup do
        @user = User.make(:annika)
        @tracked = Lead.make(:erich, :tracker_ids => [@user.id])
        @untracked = Lead.make(:markus)
      end

      should 'return leads which are tracked by the supplied user' do
        assert_equal 1, Lead.tracked_by(@user).count
        assert_equal [@tracked], Lead.tracked_by(@user)
        @tracked.update :tracker_ids => [User.make(:benny).id]
        assert_equal 0, Lead.tracked_by(@user).count
      end
    end

    context 'with_status' do
      setup do
        @new = Lead.make(:erich)
        @rejected = Lead.make(:markus)
      end

      should 'return leads with any of the supplied statuses' do
        assert_equal [@new], Lead.with_status('New').to_a
        assert_equal [@rejected], Lead.with_status('Rejected').to_a
        assert_includes Lead.with_status(%w(New Rejected)), @new
        assert_includes Lead.with_status(%w(New Rejected)), @rejected
        assert_equal 2, Lead.with_status(['New', 'Rejected']).count
      end
    end

    context 'not_deleted' do
      setup do
        @new = Lead.make(:erich)
        @rejected = Lead.make(:markus)
        @deleted = Lead.make(:kerstin)
      end

      should 'return all leads which are not deleted' do
        assert_equal 2, Lead.not_deleted.count
        refute_includes Lead.not_deleted, @deleted
      end
    end

    context 'permitted_for' do
      setup do
        @erich = Lead.make(:erich, :permission => 'Public')
        @markus = Lead.make(:markus, :permission => 'Public')
      end

      should 'return all public leads' do
        assert_includes Lead.permitted_for(@erich.user), @erich
        assert_includes Lead.permitted_for(@erich.user), @markus
      end

      should 'return all leads belonging to the user' do
        @erich.update :permission => 'Private'
        assert_includes Lead.permitted_for(@erich.user), @erich
      end

      should 'NOT return private leads belonging to another user' do
        @markus.update :permission => 'Private'
        refute_includes Lead.permitted_for(@erich.user), @markus
      end

      should 'return private leads when assigned to this user' do
        @markus.update :permission => 'Private', :assignee => @erich.user
        assert_includes Lead.permitted_for(@erich.user), @markus
      end

      should 'return shared leads where the user is in the permitted user list' do
        @markus.update :permission => 'Shared', :permitted_user_ids => [@markus.user.id, @erich.user.id]
        assert_includes Lead.permitted_for(@erich.user), @markus
      end

      should 'NOT return shared leads where the user is not in the permitted user list' do
        @markus.update :permission => 'Shared', :permitted_user_ids => [@markus.user.id]
        refute_includes Lead.permitted_for(@erich.user), @markus
      end

      context 'when freelancer' do
        setup do
          @freelancer = User.make :role => 'Freelancer'
        end

        should 'not return all public leads' do
          assert_blank Lead.permitted_for(@freelancer)
        end

        should 'return all leads belonging to the user' do
          @erich.update :user_id => @freelancer.id, :permission => 'Private'
          assert_includes Lead.permitted_for(@freelancer), @erich
        end

        should 'NOT return private leads belonging to another user' do
          @markus.update :permission => 'Private'
          assert_blank Lead.permitted_for(@freelancer)
        end

        should 'return shared leads where the user is in the permitted user list' do
          @markus.update :permission => 'Shared', :permitted_user_ids => [@markus.user_id, @freelancer.id]
          assert_includes Lead.permitted_for(@freelancer), @markus
        end

        should 'NOT return shared leads where the user is not in the permitted user list' do
          @markus.update :permission => 'Shared', :permitted_user_ids => [@markus.user_id]
          refute_includes Lead.permitted_for(@erich.user), @markus
        end
      end
    end
  end

  context 'Instance' do
    setup do
      @lead = Lead.make_unsaved(:erich, :user => User.make)
      @user = User.make(:benny)
    end

    context 'similar' do
      setup do
        FakeWeb.allow_net_connect = true
        @lead = Lead.make :company => '1000JobBoersen'
        @lead2 = Lead.new :company => '10000JobBoersen'
        @lead3 = Lead.make :company => 'JobBoersen'
        @search = Lead.search { keywords 'JobBoersen' }
        @search.stubs(:results).returns([@lead, @lead2, @lead3])
        Lead.stubs(:search).returns(@search)
      end

      should 'find all leads with similar company name' do
        assert @lead2.similar(0.9).include?(@lead)
      end

      should 'find only very similar leads with the threshold turned up' do
        assert !@lead2.similar(0.9).include?(@lead3)
      end

      should 'be able to turn the threshold down to get leads which are less similar' do
        assert @lead2.similar(0.3).include?(@lead3)
      end
    end

    should 'always store permitted user ids as BSON::ObjectIds' do
      @lead.permitted_user_ids = [@user.id.to_s]
      assert_equal [@user.id], @lead.permitted_user_ids
      user = User.make
      @lead.permitted_user_ids = [user.id]
      assert_equal [user.id], @lead.permitted_user_ids
    end

    should 'not be able to assign to another user if the permission is private' do
      @lead.save
      @lead.update :permission => 'Private'
      assert @lead.valid?
      @lead.assignee = @user
      refute @lead.valid?
      assert_includes @lead.errors[:permission], 'Cannot assign a private lead to another user, please change the permissions first'
    end

    should 'not be able to assign to another user if the permission is shared and the user is not in the permitted users list' do
      @lead.save
      user = User.make
      @lead.update :permission => 'Shared', :permitted_user_ids => [user.id]
      assert @lead.valid?
      @lead.assignee = @user
      refute @lead.valid?
      assert_includes @lead.errors[:permission], 'Cannot assign a shared lead to a user it is not shared with. Please change the permissions first'
    end

    should 'be able to get fields in pipe deliminated format' do
      assert_equal @lead.deliminated('|', ['first_name', 'last_name']), 'Erich|Feldmeier'
    end

    should 'be assigned an identifier on creation' do
      assert_nil @lead.identifier
      @lead.save
      assert @lead.identifier
    end

    should 'be assigned consecutive identifiers' do
      @lead.save
      assert_equal 1, @lead.identifier
      @lead2 = Lead.make_unsaved
      assert_nil @lead2.identifier
      @lead2.save
      assert_equal 2, @lead2.identifier
    end

    context 'changing the assignee' do
      should 'notify assignee' do
        @lead.assignee = User.make
        @lead.save
        Resque.expects(:enqueue).twice
        @lead.update :assignee_id => @user.id
        assert_equal @user, @lead.assignee
      end

      should 'not notify assignee if do_not_notify is set' do
        @lead.assignee = User.make
        @lead.save
        ActionMailer::Base.deliveries.clear
        @lead.update :assignee_id => @user.id, :do_not_notify => true
        assert_equal 0, ActionMailer::Base.deliveries.length
      end

      should 'not try to send an email if the assignee is blank' do
        @lead.assignee_id = @user.id
        @lead.save
        ActionMailer::Base.deliveries.clear
        @lead.update :assignee => nil
        assert_equal 0, ActionMailer::Base.deliveries.length
      end

      should 'not notify the assignee if the lead is a new record' do
        ActionMailer::Base.deliveries.clear
        @lead.assignee_id = @lead.user.id
        @lead.save
        assert_equal 0, ActionMailer::Base.deliveries.length
      end

      should 'set the assignee_id' do
        @lead.assignee_id = @user.id
        @lead.save
        assert_equal @lead.assignee, @user
      end
    end

    context 'activity logging' do
      setup do
        @lead.save
        @lead.reload
      end

      should 'not log a "created" activity when do_not_log is set' do
        lead = Lead.make(:erich, :do_not_log => true)
        assert_equal 0, lead.activities.count
      end

      should 'log an activity when created' do
        assert_equal 1, @lead.activities.count

        actions = @lead.activities.map &:action
        assert_includes actions, 'Created'
      end

      should 'log an activity when updated' do
        @lead = Lead.get(@lead.id)
        @lead.update :first_name => 'test'

        actions = @lead.activities.map &:action
        assert_includes actions, 'Updated'
      end

      should 'not log an "updated" activity when do_not_log is set' do
        lead = Lead.make(:erich, :do_not_log => true)
        lead.update :do_not_log => true
        assert_equal 0, lead.activities.count
      end

      should 'log an activity when destroyed' do
        @lead = Lead.get(@lead.id)
        @lead.destroy

        actions = @lead.activities.map &:action
        assert_includes actions, 'Deleted'
      end

      should 'log an activity when converted' do
        @lead = Lead.get(@lead.id)
        @lead.promote!('A new company')

        actions = @lead.activities.map &:action
        assert_includes actions, 'Converted'
      end

      should 'not log an update activity when converted' do
        @lead = Lead.get(@lead.id)
        @lead.promote!('A company')

        actions = @lead.activities.map &:action
        refute_includes actions, 'Updated'
      end

      should 'log an activity when rejected' do
        @lead = Lead.get(@lead.id)
        @lead.reject!

        actions = @lead.activities.map &:action
        assert_includes actions, 'Rejected'
      end

      should 'not log an update activity when rejected' do
        @lead = Lead.get(@lead.id)
        @lead.reject!

        actions = @lead.activities.map &:action
        refute_includes actions, 'Updated'
      end

      should 'log an activity when restored' do
        @lead.destroy
        @lead = Lead.get(@lead.id)
        @lead.update :deleted_at => nil

        actions = @lead.activities.map &:action
        assert_includes actions, 'Restored'
      end

      should 'have related activities' do
        @lead.comments.create :subject => 'afefa', :text => 'asfewfewa', :user => @lead.user
        assert_includes @lead.related_activities, @lead.comments.first.activities.first
      end
    end

    context 'promote!' do
      setup do
        @lead.save
      end

      should 'create a new account (account_type: "Prospect") and contact when a new account is specified' do
        @lead.promote!('Super duper company')

        account = Account.first(
          :name => 'Super duper company',
          :account_type => 'Prospect'
        )

        refute_nil account

        contacts = account.contacts.map { |c| [c.first_name, c.last_name] }
        assert_includes contacts, [@lead.first_name, @lead.last_name]
      end

      should 'change the lead status to "converted"' do
        @lead.promote!('A company')
        assert @lead.status_is?('Converted')
      end

      should 'assign lead to contact' do
        @lead.promote!('company name')
        assert_includes Account.first(:conditions => { :name => 'company name' }).contacts.first.leads, @lead
        assert_equal @lead.reload.contact, Account.first(:conditions => { :name => 'company name' }).contacts.first
      end

      should 'assign account to user' do
        @lead.promote!('A company')
        assert_equal @lead.user, Account.first.assignee
      end

      should 'be able to specify a "Private" permission level' do
        @lead.promote!('A company', :permission => 'Private')
        assert_equal 'Private', Account.first.permission
        assert_equal 'Private', Contact.first.permission
      end

      should 'be able to specify a "Shared" permission level' do
        @lead.promote!('A company', :permission => 'Shared', :permitted_user_ids => [@lead.user_id])
        assert_equal 'Shared', Account.first.permission
        assert_equal [@lead.user_id], Account.first.permitted_user_ids
        assert_equal 'Shared', Contact.first.permission
        assert_equal [@lead.user_id], Contact.first.permitted_user_ids
      end

      should 'be able to use leads permission level' do
        @lead.update :permission => 'Shared', :permitted_user_ids => [@lead.user_id]
        @lead.promote!('A company', :permission => 'Object')
        assert_equal @lead.permission, Account.first.permission
        assert_equal @lead.permitted_user_ids, Account.first.permitted_user_ids
        assert_equal @lead.permission, Contact.first.permission
        assert_equal @lead.permitted_user_ids, Contact.first.permitted_user_ids
      end

      should 'return an invalid account without an account name' do
        account, contact = @lead.promote!('')
        refute account.errors.blank?
      end

      should 'not create a contact when account is invalid' do
        @lead.promote!('')
        assert_equal 0, Contact.count
      end

      should 'not convert lead when account is invalid' do
        @lead.promote!('')
        assert_equal 'New', @lead.reload.status
      end

      should 'return existing contact and account if a contact already exists with the same email' do
        @lead.update :email => 'florian.behn@careermee.com'
        @contact = Contact.make(:florian, :email => 'florian.behn@careermee.com')
        @lead.promote!('')
        assert_equal 1, Contact.count
        assert_equal 'Converted', @lead.reload.status
      end

      should 'save the lead if additional attributes where added before callling promote' do
        @lead.updater_id = @user.id
        @lead.promote!('A company', :permission => 'Object')
        assert_equal @user.id, @lead.reload.updater_id
      end

      should 'create an opportunity if required' do
        @lead.promote!('A company', :opportunity => { :title => 'An opportunity', :stage =>
          OpportunityStage.first })
        assert_equal 1, @lead.contact.opportunities.count
      end

      should 'return an account, a contact and an opportunity' do
        result = @lead.promote!('A company', :opportunity => { :title => 'An opportunity',
          :stage => OpportunityStage.first })
        assert_equal [@lead.contact.account, @lead.contact, @lead.contact.opportunities.first],
          result
      end

      should 'return an account, a contact and an opportunity even when an opportunity is not created' do
        account, contact, opportunity = @lead.promote!('A company')
        assert_kind_of Account, account
        assert_kind_of Contact, contact
        assert_kind_of Opportunity, opportunity
        assert_blank opportunity.errors
      end

      should 'not create an account or contact if an opportunity is supplied, and the opportunity is invalid' do
        account, contact, opportunity = @lead.promote!(
          'A company',
          :opportunity => { :title => 'An opportunity', :amount => 'asf' }
        )
        assert_equal 0, Account.count
        assert_equal 0, Contact.count
        assert_equal 0, Opportunity.count
      end

      should 'still return an account if the contact exists, but it does not have an account' do
        @lead.update :email => 'florian.behn@careermee.com'
        @contact = Contact.make(:florian, :email => 'florian.behn@careermee.com', :account => nil)
        assert_blank @contact.account
        result = @lead.promote!('New Account')
        assert_equal 1, Account.count
        refute @contact.reload.account.blank?
        assert_kind_of Account, result.first
        assert_kind_of Contact, result[1]
      end

      should 'return nil instead of account if the contact exists, but it does not have an account, and no name is specified' do
        @lead.update :email => 'florian.behn@careermee.com'
        @contact = Contact.make(:florian, :email => 'florian.behn@careermee.com', :account => nil)
        result = @lead.promote!('')
        assert_nil result.first
      end

      should 'not set the contact account id if the contact exists without an account, and the new account is invalid' do
        @lead.update :email => 'florian.behn@careermee.com'
        @contact = Contact.make(:florian, :email => 'florian.behn@careermee.com', :account => nil)
        @lead.promote!('')
        assert_blank @contact.reload.account_id
      end

      should 'not attempt to assign to a contact if the email is blank' do
        @lead.update :email => ''
        @contact = Contact.make(:florian, :email => '')
        @lead.promote!('an account')
        assert_equal 2, Contact.count
        refute_includes @contact.leads, @lead
      end
    end

    should 'require last name' do
      @lead.last_name = nil
      refute @lead.valid?
      assert @lead.errors[:last_name]
    end

    should 'require user id' do
      @lead.user = nil
      refute @lead.valid?
      assert @lead.errors[:user]
    end

    should 'require at least one permitted user if permission is "Shared"' do
      @lead.permission = 'Shared'
      refute @lead.valid?, "Expected lead to be invalid, but was valid"
      assert @lead.errors[:permitted_user_ids]
    end

    should 'be valid' do
      assert @lead.valid?
    end

    should 'have full_name' do
      assert_equal 'Erich Feldmeier', @lead.full_name
    end

    should 'alias full_name to name' do
      assert_equal @lead.name, @lead.full_name
    end

    should 'start with status "New"' do
      @lead.save
      assert_equal 'New', @lead.status
    end

    should 'start with different status if one is specified' do
      @lead.status = 'Rejected'
      @lead.save
      assert_equal 'Rejected', @lead.status
    end
  end
end
