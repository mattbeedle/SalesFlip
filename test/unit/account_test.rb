require 'test_helper.rb'

class AccountTest < ActiveSupport::TestCase
  context 'Class' do
    should_have_constant :accesses
    should_act_as_paranoid
    should_be_trackable
    should_have_key :user_id, :assignee_id, :name, :email, :access, :website, :phone, :fax,
      :billing_address, :shipping_address
    should_require_key :user_id, :name
    should_belong_to :user, :assignee
    should_have_many :contacts, :tasks, :comments

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
          @lead.update_attributes :updater_id => nil
          Account.create_for(@lead, 'CareerMee')
        end

        should 'create account for lead, using leads creator' do
          assert_equal 1, @user.accounts.count
        end
      end

      context 'when lead has updater' do
        setup do
          @lead.update_attributes :updater_id => @benny.id
          Account.create_for(@lead, 'CareerMee')
        end

        should 'create account for lead, using leads updater' do
          assert_equal 1, @benny.accounts.count
        end
      end

      context 'when lead permission is specified' do
        setup do
          @lead.update_attributes :permission => 'Private'
          Account.create_for(@lead, 'CareerMee', :permission => 'Object')
        end

        should 'create account with the same permission as the lead' do
          assert_equal 1, Account.count
          assert_equal 'Private', Account.first.permission
        end
      end

      context 'when custom permission is specified' do
        should 'create account with the custom permissions' do
          Account.create_for(@lead, 'CareerMee', :permission => 'Shared', :permitted_user_ids => [@benny.id])
          assert_equal 1, Account.count
          assert_equal 'Shared', Account.first.permission
          assert_equal [@benny.id], Account.first.permitted_user_ids
        end
      end

      context 'when account is invalid' do
        should 'return an invalid account' do
          @account = Account.create_for(@lead, 'CareerMee', :permission => 'Shared', :permitted_user_ids => [])
          assert !@account.valid?
        end
      end
    end
  end

  context 'Instance' do
    setup do
      @account = Account.make_unsaved(:careermee)
    end

    should 'validate uniqueness of email' do
      @account.email = 'test@test.com'
      @account.save!
      a = Account.make_unsaved(:careermee, :email => 'test@test.com')
      assert !a.valid?
      assert a.errors.on(:email)
    end

    context 'permitted_for' do
      setup do
        @annika = User.make(:annika)
        @benny = User.make(:benny)
        @careermee = Account.make(:careermee, :user => @annika, :permission => 'Public')
        @world_dating = Account.make(:world_dating, :user => @benny, :permission => 'Public')
      end

      should 'return all public contacts' do
        assert Account.permitted_for(@annika).include?(@careermee)
        assert Account.permitted_for(@annika).include?(@world_dating)
      end

      should 'return all contacts belonging to the user' do
        @careermee.update_attributes :permission => 'Private'
        assert Account.permitted_for(@annika).include?(@careermee)
      end

      should 'NOT return private contacts belonging to another user' do
        @world_dating.update_attributes :permission => 'Private'
        assert !Account.permitted_for(@annika).include?(@world_dating)
      end

      should 'return shared contacts where the user is in the permitted users list' do
        @world_dating.update_attributes :permission => 'Shared', :permitted_user_ids => [@annika.id]
        assert Account.permitted_for(@annika).include?(@world_dating)
      end

      should 'NOT return shared contacts where the user is not in the permitted users list' do
        @world_dating.update_attributes :permission => 'Shared', :permitted_user_ids => [@world_dating.id]
        assert !Account.permitted_for(@annika).include?(@world_dating)
      end
    end

    context 'activity logging' do
      setup do
        @account.save
        @account = Account.find(@account.id)
      end

      should 'log an activity when created' do
        assert @account.activities.any? {|a| a.action == 'Created' }
      end

      should 'log an activity when updated' do
        @account.update_attributes :name => 'an update test'
        assert_equal 2, @account.activities.count
        assert @account.activities.any? {|a| a.action == 'Updated' }
      end

      should 'not log an update activity when created' do
        assert_equal 1, @account.activities.length
      end

      should 'log an activity when deleted' do
        @account.destroy
        assert @account.activities.any? {|a| a.action == 'Deleted' }
      end

      should 'log an activity when restored' do
        @account.destroy
        @account = Account.find(@account.id)
        @account.update_attributes :deleted_at => nil
        assert @account.activities.any? {|a| a.action == 'Restored' }
      end
    end

    should 'require at least one permitted user if permission is "Shared"' do
      @account.permission = 'Shared'
      assert !@account.valid?
      assert @account.errors.on(:permitted_user_ids)
    end

    should 'require name' do
      @account.name = nil
      assert !@account.valid?
      assert @account.errors.on(:name)
    end

    should 'require user' do
      @account.user_id = nil
      assert !@account.valid?
      assert @account.errors.on(:user_id)
    end

    should 'be valid' do
      assert @account.valid?
    end
    
    context 'named scope' do
      setup do
        @ann    = User.make    :annika, :email=>'an@an.com'
        @ben    = User.make    :benny
        @stevo  = User.make    :steven
        @acme   = Account.make :name => 'Acme', :user => @ann,   :permission => 'Public'
        @aol    = Account.make :name => 'AOL',  :user => @ben,   :permission => 'Public'
        @bing   = Account.make :name => 'Bing', :user => @stevo, :permission => 'Public'
      end

      should 'return accounts where the name matches the query' do
        assert_equal [@acme,@aol], Account.named("A")
        assert_equal [@acme], Account.named("Ac")
        assert_equal [@bing], Account.named("b")
      end
      
    end
    
  end
end
