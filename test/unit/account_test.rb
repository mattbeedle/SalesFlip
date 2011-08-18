require 'test_helper.rb'

class AccountTest < ActiveSupport::TestCase
  context 'Class' do
    should_have_constant :account_types
    should_act_as_paranoid
    should_be_trackable
    should_have_key :user_id, :assignee_id, :name, :email, :access, :website, :phone, :fax,
      :billing_address, :shipping_address, :account_type
    should_require_key :user, :name
    should_belong_to :user, :assignee
    should_have_many :contacts, :tasks, :comments

    should 'be able to return accounts with similar names to the one provided' do
      account1 = Account.make(:careermee)
      account2 = Account.make(:name => 'CareerWee')
      account3 = Account.make(:name => 'careermee')
      account4 = Account.make(:world_dating)

      assert_equal 2, Account.similar_to(Account.new(name: 'CareerMee')).count
      assert !Account.similar_to(Account.new(name: 'CareerMee')).include?(account4)
      assert_equal 1, Account.similar_to(Account.new(name: 'World dating')).count
    end

    should 'be able to have a parent' do
      @parent = Account.make(:careermee)
      @child = Account.make(:name => 'CareerWee')
      @child.parent = @parent
      @child.save
      @child = Account.get(@child.id)
      assert_equal @parent, @child.parent
    end

    should 'be able to have a child' do
      @child = Account.make(:careermee)
      @parent = Account.make(:name => 'CareerWee')
      @parent.children << @child
      @parent = Account.get(@parent.id)
      assert @parent.children.include?(@child)
    end

    should 'be able to have a child (2)' do
      @child = Account.make
      @parent = Account.make
      @child.parent = @parent
      @child.save
      assert_equal @child, @parent.children.first
    end

    should 'know which fields can be exported' do
      Account.properties.map(&:name).each do |field|
        field = field.to_s
        unless field == 'access' || field == 'tracker_ids'
          assert Account.exportable_fields.include?(field)
        else
          assert !Account.exportable_fields.include?(field)
        end
      end
    end

    context 'assigned_to' do
      setup do
        @careermee = Account.make(:careermee)
        @world_dating = Account.make(:world_dating)
        @mystery_account = Account.make(:assignee => @careermee.user)
      end

      should 'return accounts which are assigned to the supplied user' do
        assert Account.assigned_to(@careermee.user.id).include?(@mystery_account)
      end

      should 'return accounts which were created by the supplied user, and are not assigned' do
        assert Account.assigned_to(@careermee.user.id).include?(@careermee)
      end

      should 'not return accounts which were created by the supplied user, but are assigned to someone else' do
        assert !Account.assigned_to(@mystery_account.user.id).include?(@mystery_account)
      end

      should 'not return accounts that have nothing to do with the supplied user' do
        accounts = Account.assigned_to(@mystery_account.user.id)
        assert !accounts.include?(@careermee)
        assert !accounts.include?(@world_dating)
      end

      should 'still work with a string arguement' do
        assert Account.assigned_to(@careermee.user.id.to_s).include?(@mystery_account)
      end
    end

    context 'find_or_create_for' do
      setup do
        @lead = Lead.make(:erich)
        @account = Account.make(:careermee)
      end

      context 'when account exists' do
        should 'return the existing account' do
          assert_equal @account, Account.find_or_create_for(@lead, @account.name)
          assert_equal 1, Account.count
        end
      end

      context 'when the account does not exist' do
        should 'create a new account' do
          Account.find_or_create_for(@lead, 'test')
          assert_equal 2, Account.count
        end
      end

      context 'when an id is specified instead of a name' do
        should 'return the account' do
          assert_equal @account, Account.find_or_create_for(@lead, @account.id)
          assert_equal 1, Account.count
        end
      end
    end

    context 'create_for' do
      setup do
        @user = User.make(:annika)
        @benny = User.make(:benny)
        @lead = Lead.make(:erich, :user => @user)
      end

      context 'when lead does not have updater' do
        setup do
          @lead.update :updater_id => nil
          Account.create_for(@lead, 'CareerMee')
        end

        should 'create account for lead, using leads creator' do
          assert_equal 1, @user.accounts.count
        end
      end

      context 'when lead has updater' do
        setup do
          @lead.update :updater_id => @benny.id
          Account.create_for(@lead, 'CareerMee')
        end

        should 'create account for lead, using leads updater' do
          assert_equal 1, @benny.accounts.count
        end
      end
    end
    
    context 'for_company' do
      setup do
        @account = Account.make
        @account2 = Account.make
      end

      should 'only return accounts for the supplied company' do
        assert_equal @account, Account.for_company(@account.user.company).first
        assert_equal 1, Account.for_company(@account.user.company).count
        assert_equal @account2, Account.for_company(@account2.user.company).first
        assert_equal 1, Account.for_company(@account2.user.company).count
      end
    end

    context 'name_like' do
      setup do
        @careermee = Account.make(:careermee)
        @world_dating = Account.make(:world_dating)
      end

      should 'only return accounts with a name like the one specified' do
        assert_equal [@careermee], Account.name_like('CareerMee').to_a
        assert_equal [@world_dating], Account.name_like('World').to_a
      end
    end
  end

  context 'Instance' do
    setup do
      @account = Account.make_unsaved(:careermee, :user => User.make)
      @user = User.make
    end
    
    should 'be able to get all related leads' do
      contact = Contact.make(:account => @account)
      lead = Lead.make(:contact => contact)
      contact2 = Contact.make(:account => @account)
      lead2 = Lead.make(:contact => contact2)
      assert @account.leads.include?(lead)
      assert @account.leads.include?(lead2)
      assert_equal 2, @account.leads.length
    end

    should 'include activities for related contacts in related_activities' do
      contact = Contact.make(:account => @account)
      assert @account.related_activities.include?(contact.activities.first)
    end

    should 'include activities for related leads in related_activities' do
      contact = Contact.make(:account => @account)
      lead = Lead.make(:contact => contact)
      assert @account.related_activities.include?(lead.activities.first)
    end

    should 'include activities for related tasks in related_activities' do
      contact = Contact.make(:account => @account)
      lead = Lead.make(:contact => contact)
      task = Task.make(:asset => contact)
      task2 = Task.make(:asset => lead)
      assert_includes @account.related_activities, task.activities.first
      assert_includes @account.related_activities, task2.activities.first
    end

    should 'include activities for related comments and emails in related_activities' do
      contact = Contact.make(:account => @account)
      lead = Lead.make(:contact => contact)
      comment = Comment.make(:commentable => contact)
      comment2 = Comment.make(:commentable => lead)
      email = Email.make(:commentable => contact)
      email2 = Email.make(:commentable => lead)
      assert_includes @account.related_activities, comment.activities.first
      assert_includes @account.related_activities, comment2.activities.first
      assert_includes @account.related_activities, email.activities.first
      assert_includes @account.related_activities, email2.activities.first
    end

    should 'be able to get fields in pipe deliminated format' do
      assert_equal @account.deliminated('|', ['name', 'user_id']), "\"CareerMee\"|\"#{@account.user_id}\""
    end

    should 'ensure http:// is prepended to uris' do
      @account.website = 'test.com'
      assert_equal 'http://test.com', @account.website
    end

    should 'not prepend http:// if it is already there' do
      @account.website = 'http://test.com'
      assert_equal 'http://test.com', @account.website
    end

    should 'not prepend http:// if the uri is nil' do
      @account.website = nil
      assert @account.website.nil?
    end

    should 'validate uniqueness of email' do
      @account.email = 'test@test.com'
      @account.save
      a = Account.make_unsaved(:careermee, :email => 'test@test.com')
      assert !a.valid?
      assert a.errors[:email]
    end

    context 'activity logging' do
      setup do
        @account.save
      end

      should 'log an activity when created' do
        activities = @account.activities.map &:action
        assert_includes activities, 'Created'
      end

      should 'log an activity when updated' do
        @account.update :name => 'an update test'
        assert_equal 2, @account.activities.count
        activities = @account.activities.map &:action
        assert_includes activities, 'Updated'
      end

      should 'not log an update activity when created' do
        assert_equal 1, @account.activities.length
      end

      should 'log an activity when deleted' do
        @account.destroy
        activities = @account.activities.map &:action
        assert_includes activities, 'Deleted'
      end

      should 'log an activity when restored' do
        @account.destroy
        @account = Account.last
        @account.update :deleted_at => nil
        activities = @account.activities.map &:action
        assert_includes activities, 'Restored'
      end
    end

    should 'require name' do
      @account.name = nil
      assert !@account.valid?
      assert @account.errors[:name]
    end

    should 'require user' do
      @account.user = nil
      assert !@account.valid?
      assert @account.errors[:user_id]
    end

    should 'be valid' do
      assert @account.valid?
    end
  end
end
