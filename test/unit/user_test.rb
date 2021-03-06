require 'test_helper.rb'

class UserTest < ActiveSupport::TestCase
  context 'Class' do
    should_have_key :company_id
    should_require_key :email, :company
    should_belong_to :company
    should_have_instance_methods :company_name=, :company_name
    should_have_many :invitations, :leads, :comments, :tasks, :accounts, :contacts, :activities,
      :searches, :opportunities, :assigned_opportunities, :emails, :lead_imports
    should_have_constant :roles

    context 'send_tracked_items_mail' do
      setup do
        @user = User.make(:annika)
        @benny = User.make(:benny)
        @lead = Lead.make(:erich, :user => @user, :tracker_ids => [@benny.id])
        @comment = @lead.comments.create :user => @user, :subject => 'a comment',
          :text => 'This is a good lead'
        @email = Email.create :user => @benny, :subject => 'an offer',
          :text => 'Here is your offer', :commentable => @lead, :from => 'test@test.com',
          :received_at => Time.zone.now
        @attachment = @email.attachments.create \
          :attachment => File.open('test/upload-files/erich_offer.pdf')
        @task = @lead.tasks.create :name => 'Call this guy', :due_at => 'due_today',
          :category => 'Call', :user => @user
        ActionMailer::Base.deliveries.clear
      end

      should 'should add users id to notified_users list of all actions which were emailed' do
        User.send_tracked_items_mail
        assert @lead.related_activities.all? {|a| a.notified_user_ids.include?(@benny.id) }
      end

      should 'send tracked items email with all new activities included' do
        User.send_tracked_items_mail
        assert_sent_email do |email|
          email.body =~ /#{@lead.name}/ && email.body =~ /#{@comment.text}/ &&
            email.body =~ /#{@email.text}/ && email.body =~ /#{@task.name}/ &&
            email.body =~ /#{@attachment.attachment.filename}/ && email.to.include?(@benny.email)
        end
      end

      should 'not email users who are not tracking any items' do
        User.send_tracked_items_mail
        assert_sent_email do |email|
          !email.to.include?(@user)
        end
      end

      should 'not include activities in the email which have already been sent in a previous email' do
        User.send_tracked_items_mail
        comment2 = @lead.comments.create :subject => 'another comment',
          :text => 'a second comment', :user => @user
        ActionMailer::Base.deliveries.clear
        User.send_tracked_items_mail
        assert_sent_email do |email|
          email.body.match(/#{@lead.name}/) && !email.body.match(/#{@comment.text}/) &&
            !email.body.match(/#{@email.text}/) && !email.body.match(/#{@task.name}/) &&
            !email.body.match(/#{@attachment.attachment.filename}/) &&
            email.to.include?(@benny.email) && email.body.match(/#{comment2.text}/)
        end
      end

      should 'not send an email at all if there are no new activities' do
        User.send_tracked_items_mail
        ActionMailer::Base.deliveries.clear
        User.send_tracked_items_mail
        assert_equal 0, ActionMailer::Base.deliveries.length
      end

      should 'have todays date in the subject' do
        User.send_tracked_items_mail
        assert_sent_email do |email|
          email.subject =~ /#{Date.today.to_s(:long)}/
        end
      end
    end
  end

  context 'Instance' do
    setup do
      @user = User.make_unsaved(:annika, :company => Company.make(:jobboersen))
    end

    context "when communicating with salesflip" do

      setup do
        @key = Rails.configuration.external_access_key
      end

      should "has an external access key" do
        assert_not_nil @key
      end
    end

    context "when saving a user" do

      setup do
        @user = User.make_unsaved
      end

      should "enqueues the update external job" do
        Resque.expects(:enqueue).with(UpdateExternalUserJob, @user.to_json)
        @user.update_external_user
      end
    end

    context '#redistribute_leads' do
      setup do
        @user.save!
        4.times do
          Lead.make(:status => 'New', :user => @user, :assignee => @user)
        end
      end

      should 'assign all leads to the rest of the sales team' do
        user = User.make :company => @user.company
        @user.redistribute_leads
        assert_equal 4, Lead.assigned_to(user).count
      end

      should 'not assign any leads to the service team' do
        user = User.make :company => @user.company, :role => 'Service Person'
        @user.redistribute_leads
        assert_equal 0, Lead.assigned_to(user).count
      end

      should 'unassign all leads from salesperson' do
        User.make :company => @user.company
        @user.redistribute_leads
        assert_equal 0, Lead.assigned_to(@user).count
      end

      should 'not redistribute leads when there are no other sales people' do
        @user.redistribute_leads
        assert_equal 4, Lead.assigned_to(@user).count
      end

      should 'be able to specify sales people' do
        user = User.make :company => @user.company
        user2 = User.make :company => @user.company
        user3 = User.make :company => @user.company
        @user.redistribute_leads(users: [user2, user3])
        assert_equal 2, Lead.assigned_to(user2).count
        assert_equal 2, Lead.assigned_to(user3).count
        assert_equal 0, Lead.assigned_to(user).count
      end

      should 'also assign tasks' do
        user = User.make company: @user.company, role: 'Sales Person'
        Lead.first.tasks.create name: 'Do something', category: 'Call',
          due_at: Time.now, user: @user
        @user.redistribute_leads
        assert_equal 1, Task.assigned_to(user).count
      end
    end

    should 'default role to "Sales Person"' do
      @user.role = nil
      @user.save
      assert @user.role_is?('Sales Person')
    end

    should 'not default role to "Sales Person" if a role is already set' do
      @user.role = 'Freelancer'
      @user.save
      assert @user.role_is?('Freelancer')
    end

    should 'create company from company name' do
      @user = User.make(:annika, :company_name => 'A test company', :company => nil)
      assert Company.first(:conditions => { :name => 'A test company' })
      assert_equal 'A test company', @user.company.name
    end

    should 'have dropbox email' do
      @user.save
      assert_equal "#{@user.api_key}@salesflip.appspotmail.com", @user.dropbox_email
    end

    context 'when invited' do
      setup do
        @user.save
        @invitation = Invitation.make :inviter => @user, :role => 'Freelancer',
          :email => 'test@test.com'
      end

      should 'populate details from invitation code' do
        user = User.new :invitation_code => @invitation.code
        assert_equal 'test@test.com', user.email
        assert_equal 'test', user.username
        assert_equal 'Freelancer', user.role
        assert_equal @user.company_id, user.company_id
      end

      should 'be able to override invitation code details' do
        user = User.new :invitation_code => @invitation.code, :username => 'wtf', :email => 'wtf'
        assert_equal 'wtf', user.email
        assert_equal 'wtf', user.username
      end

      should 'update invitation with invited id after creation' do
        user = User.new :invitation_code => @invitation.code, :password => 'password',
          :password_confirmation => 'password'
        user.save
        assert user.invitation
      end
    end

    should 'update invitation with invited id after create' do
      @user.save
    end

    context 'deleted_items_count' do
      setup do
        @user.save
        @lead = Lead.make
        @contact = Contact.make
        @account = Account.make
      end

      should 'return a count of all deleted accounts, contacts and leads' do
        assert_equal 0, @user.deleted_items_count
        @lead.destroy
        assert_equal 1, @user.deleted_items_count
        @contact.destroy
        assert_equal 2, @user.deleted_items_count
        @account.destroy
        assert_equal 3, @user.deleted_items_count
      end

      should 'not count permanently deleted items' do
        @lead.destroy
        @lead.destroy_without_paranoid
        assert_equal 0, @user.deleted_items_count
      end
    end

    context 'full_name' do
      should 'return username if present' do
        @user.username = 'annie'
        assert_equal @user.full_name, "annie"
      end

      should 'return email username if username is not present' do
        @user.username = nil
        @user.save
        assert_equal @user.full_name, "annika.fleischer1"
      end
    end

    context 'tracked_items' do
      setup do
        @user.save
      end

      should 'return all tracked leads' do
        lead = Lead.make(:erich, :tracker_ids => [@user.id])
        assert @user.tracked_items.include?(lead)
      end

      should 'return all tracked contacts' do
        contact = Contact.make(:florian, :tracker_ids => [@user.id])
        assert @user.tracked_items.include?(contact)
      end

      should 'return all tracked accounts' do
        account = Account.make(:careermee, :tracker_ids => [@user.id])
        assert @user.tracked_items.include?(account)
      end
    end

    context 'recent_items' do
      should 'return recently viewed items' do
        @lead = Lead.make
        Activity.log(@user, @lead, 'Viewed')
        assert @user.recent_items.include?(@lead)
      end

      should 'not return nil subjects' do
        Activity.create! :user => @user, :subject => nil, :action => 'Viewed'
        assert_equal 0, @user.recent_items.length
      end

      should 'order items by when they where viewed' do
        @lead = Lead.make
        @contact = Contact.make
        @contact2 = Contact.make
        Activity.log(@user, @lead, 'Viewed')
        Activity.log(@user, @contact2, 'Viewed')
        Activity.log(@user, @contact, 'Viewed')
        assert_equal [@contact, @contact2, @lead], @user.recent_items
      end

      should 'return a maximum of 15 items' do
        16.times do
          @lead = Lead.make
          Activity.log(@user, @lead, 'Viewed')
        end
        assert_equal 15, @user.recent_items.length
      end
    end

    should 'have uuid after creation' do
      @user.save
      assert !@user.api_key.blank?
    end
  end
end
