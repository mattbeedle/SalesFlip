require 'test_helper.rb'

class LeadTest < ActiveSupport::TestCase
  context 'Class' do
    should_have_key :city, :postal_code, :country, :job_title, :department, :identifier
    should_have_constant :titles, :statuses, :sources, :salutations
    should_act_as_paranoid
    should_be_trackable
    should_belong_to :user, :assignee, :contact
    should_have_many :comments, :tasks, :activities, :emails

    should 'know which fields may be exported' do
      Lead.properties.map(&:name).each do |field|
        field = field.to_s
        unless field == 'access' || field == 'tracker_ids'
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

  end

  context 'Instance' do
    setup do
      @lead = Lead.make_unsaved(:erich, user: User.make, company: 'test')
      @user = User.make(:benny)
    end

    context 'validating when converted' do
      setup do
        @lead.status = 'Converted'
        @lead.attributes = { salutation: 'Mr', phone: 'aefewaf',
                             job_title: 'whatever', email: 'test@test.com' }
      end

      should 'require salutation' do
        @lead.salutation = nil
        assert !@lead.valid?
      end

      should 'require last name' do
        @lead.last_name = nil
        assert !@lead.valid?
      end

      should 'require phone' do
        @lead.phone = nil
        assert !@lead.valid?
      end

      should 'require job title' do
        @lead.job_title = nil
        assert !@lead.valid?
      end

      should 'require email' do
        @lead.email = nil
        assert !@lead.valid?
      end

      should 'be valid with all required attributes' do
        assert @lead.valid?
      end
    end

    context 'when duplicate_check is true' do
      setup do
        results = mock()
        Lead.stubs(:search).returns(results)
        results.stubs(:results).returns([@lead])
      end

      should 'check for duplicates when validating' do
        @lead.save!
        lead = Lead.make_unsaved(:erich, user: User.make,
                                 duplicate_check: true, company: 'test')
        assert !lead.valid?
      end
    end

    context 'duplicate checking' do
      context 'when there is a duplicate' do
        setup do
          Lead.make(company: "test")
        end

        should 'not be valid if duplicate checking is on' do
          lead = Lead.new(company: 'test', duplicate_check: true)
          lead.valid?
          assert lead.errors.on(:company)
        end

        should 'be valid is duplicate checking is off' do
          lead = Lead.new(company: 'test')
          lead.valid?
          refute lead.errors.on(:company)
        end
      end

      context 'when there is no duplicate' do
        should 'be valid when duplicate checking is on' do
          lead = Lead.new(company: 'test', duplicate_check: true)
          lead.valid?
          refute lead.errors.on(:company)
        end

        should 'be valid when duplicate checking is off' do
          lead = Lead.new(company: 'test')
          lead.valid?
          refute lead.errors.on(:company)
        end
      end
    end

    should 'be able to get fields in pipe deliminated format' do
      assert_equal @lead.deliminated('|', ['first_name', 'last_name']),
        '"Erich"|"Feldmeier"'
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
        @lead.update_attributes salutation: 'Mr', job_title: 'a', phone: 'b',
          email: 'test@test.com'
        @lead.promote!('A new company',
                       opportunity: { title: 'test', budget: 1000,
                                      stage: 'New' })


        actions = @lead.activities.map &:action
        assert_includes actions, 'Converted'
      end

      should 'not log an update activity when converted' do
        @lead = Lead.get(@lead.id)
        @lead.promote!('A company',
                       opportunity: { title: 'test', stage: 'New', budget: 1000 })

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

      should 'update the contact attributes if the contact already exists' do
        contact = Contact.make(:florian, email: 'test@test.com')
        @lead.update_attributes last_name: 'test', email: 'test@test.com',
          job_title: 'a job title', phone: '999',  salutation: 'Ms'
        @lead.promote!('', opportunity: { title: 'test', budget: 1000,
                                          stage: 'New' })
        assert_equal 'test', contact.reload.last_name
        assert_equal 'a job title', contact.reload.job_title
        assert_equal '999', contact.reload.phone
        assert_equal 'Ms', contact.reload.salutation
      end

      should 'create a new account (account_type: "Prospect") and contact when a new account is specified' do
        @lead.promote!('Super duper company',
                       opportunity: { title: 'test', budget: 1000,
                                      stage: 'New' })

        account = Account.first(
          :name => 'Super duper company',
          :account_type => 'Prospect'
        )

        refute_nil account

        contacts = account.contacts.map { |c| [c.first_name, c.last_name] }
        assert_includes contacts, [@lead.first_name, @lead.last_name]
      end

      should 'change the lead status to "converted"' do
        @lead.promote!('A company',
                       opportunity: { stage: 'New', title: 'title',
                                      budget: 1000 })
        assert @lead.status_is?('Converted')
      end

      should 'assign lead to contact' do
        @lead.update_attributes salutation: 'Mr', phone: 'a', job_title: 'b',
          email: 'test@test.com'
        @lead.promote!('company name', opportunity: {
          title: 'test', budget: 1000, stage: 'New' })
        assert_includes Account.first(:conditions => { :name => 'company name' }).contacts.first.leads, @lead
        assert_equal @lead.reload.contact, Account.first(:conditions => { :name => 'company name' }).contacts.first
      end

      should 'assign account to user' do
        @lead.promote!('A company', opportunity: { title: 'test', budget: 1000,
                                                   stage: 'New' })
        assert_equal @lead.user, Account.first.assignee
      end

      should 'return an invalid account without an account name' do
        account, contact, opportunity = @lead.promote!('', opportunity: {
          title: 'test', stage: 'New', amount: 1000 })
        refute account.errors.blank?
      end

      should 'not create a contact when account is invalid' do
        @lead.promote!('', opportunity: { title: 'test', budget: 1000,
                                          stage: 'New' })
        assert_equal 0, Contact.count
      end

      should 'not convert lead when account is invalid' do
        @lead.promote!('', opportunity: { title: 'test', budget: 1000,
                                          stage: 'New' })
        assert_equal 'New', @lead.reload.status
      end

      should 'return existing contact and account if a contact already exists with the same email' do
        @lead.update :email => 'florian.behn@careermee.com', salutation: 'Mr',
          phone: 'a', job_title: 'b'

        @contact = Contact.make(:florian, :email => 'florian.behn@careermee.com')
        @lead.promote!('', opportunity: { title: 'title', budget: 1000,
                                          stage: 'New' })
        assert_equal 1, Contact.count
        assert_equal 'Converted', @lead.reload.status
      end

      should 'create an opportunity if required' do
        @lead.promote!('A company', :opportunity => { :title => 'An opportunity', :stage =>
          'New', :budget => 2000 })
        assert_equal 1, @lead.contact.opportunities.count
      end

      should 'return an account, a contact and an opportunity' do
        result = @lead.promote!('A company', :opportunity => { :title => 'An opportunity',
          :stage => 'New', :budget => 2000 })
        assert_equal [@lead.contact.account, @lead.contact, @lead.contact.opportunities.first],
          result
      end

      should 'not create an account or contact if an opportunity is supplied, and the opportunity is invalid' do
        account, contact, opportunity = @lead.promote!(
          'A company',
          :opportunity => { :title => 'An opportunity', :amount => 'asf', stage: 'New' }
        )
        assert_equal 0, Account.count
        assert_equal 0, Contact.count
        assert_equal 0, Opportunity.count
      end

      should 'still return an account if the contact exists, but it does not have an account' do
        @lead.update :email => 'florian.behn@careermee.com'
        @contact = Contact.make(:florian, :email => 'florian.behn@careermee.com', :account => nil)
        assert_blank @contact.account
        result = @lead.promote!('New Account',
                                opportunity: { title: 'test', stage: 'New',
                                               budget: 1000 })
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
        @lead.promote!('an account',
                       opportunity: { title: 'test', budget: 1000, stage: 'New' })
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

    context "attribute cleaning" do

      should 'clean company' do
        assert_equal "company", Lead.new(:company => %Q[\t'company\r\n"]).company
      end

      should 'clean first_name' do
        assert_equal "first_name", Lead.new(:first_name => %Q[\t'first_name\r\n"]).first_name
      end

      should 'clean last_name' do
        assert_equal "last_name", Lead.new(:last_name => %Q[\t'last_name\r\n"]).last_name
      end

      should 'clean email' do
        assert_equal "email", Lead.new(:email => %Q[\t'email\r\n"]).email
      end

      should 'clean phone' do
        assert_equal "phone", Lead.new(:phone => %Q[\t'phone\r\n"]).phone
      end

      should 'clean website' do
        assert_equal "website", Lead.new(:website => %Q[\t'website\r\n"]).website
      end

    end
  end
end
