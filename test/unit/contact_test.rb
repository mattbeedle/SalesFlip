require 'test_helper.rb'

class ContactTest < ActiveSupport::TestCase
  context "Class" do
    should_have_key :identifier, :city, :postal_code, :country, :job_title, :department
    should_have_constant :accesses, :titles, :salutations, :sources
    should_act_as_paranoid
    should_be_trackable
    should_belong_to :account, :user, :assignee
    should_have_many :leads, :tasks, :comments, :emails, :opportunities

    should 'know which fields can be exported' do
      Contact.properties.map {|p| p.name.to_s}.each do |field|
        unless field == 'access' || field == 'tracker_ids'
          assert_includes Contact.exportable_fields, field
        else
          refute Contact.exportable_fields.include?(field)
        end
      end
    end

    context 'assigned_to' do
      setup do
        @user = User.make
        @contact = Contact.make(:florian, :assignee => @user)
        @contact2 = Contact.make(:steven)
      end

      should 'return contacts assigned to the specified user' do
        assert_includes Contact.assigned_to(@user.id), @contact
        assert_equal 1, Contact.assigned_to(@user.id).count
      end

      should 'return contacts created by the specified user, but not assigned to anyone' do
        assert_includes Contact.assigned_to(@contact2.user.id), @contact2
        assert_equal 1, Contact.assigned_to(@contact2.user.id).count
      end

      should 'work with a string arguement' do
        assert_equal 1, Contact.assigned_to(@contact2.user.id.to_s).count
      end
    end

    context 'create_for' do
      setup do
        @account = Account.make(:careermee)
        @lead = Lead.make(:call_erich, :user => @account.user)
      end

      should 'create a contact from the supplied lead and account' do
        Contact.create_for(@lead, @account)
        assert_equal 1, Contact.count
        assert Contact.all(:first_name => @lead.first_name, :last_name => @lead.last_name).first
        assert_equal 1, @account.contacts.count
      end

      should 'assign lead to contact' do
        contact = Contact.create_for(@lead, @account)
        assert_includes contact.leads, @lead
      end

      should 'not create the contact if the supplied account is invalid' do
        @account.name = nil
        contact = Contact.create_for(@lead, @account)
        assert_equal 0, Contact.count
      end

      should 'copy all lead attributes that can be copied' do
        5.times do
          Identifier.next_contact
        end
        @lead.update :phone => '1234567890', :salutation => 'Mr',
          :department => 'a test department', :source => 'Website', :address => 'an address',
          :website => 'www.test.com', :linked_in => 'linkedin', :facebook => 'facebook',
          :xing => 'xing', :do_not_call => true
        contact = Contact.create_for(@lead, @account)
        assert_equal '1234567890', contact.phone
        assert_equal 'Mr', contact.salutation
        assert_equal 'a test department', contact.department
        assert_equal 'Website', contact.source
        assert_equal 'an address', contact.address
        assert_equal 'http://www.test.com', contact.website
        assert_equal 'linkedin', contact.linked_in
        assert_equal 'facebook', contact.facebook
        assert_equal 'xing', contact.xing
        refute_equal @lead.identifier, contact.identifier
        assert contact.do_not_call
      end
    end

    context 'for_company' do
      setup do
        @contact = Contact.make
        @contact2 = Contact.make
      end

      should 'only return contacts for the supplied company' do
        assert_equal @contact, Contact.for_company(@contact.user.company).first
        assert_equal 1, Contact.for_company(@contact.user.company).count
        assert_equal @contact2, Contact.for_company(@contact2.user.company).first
        assert_equal 1, Contact.for_company(@contact2.user.company).count
      end
    end

    context 'name_like' do
      setup do
        @contact = Contact.make :first_name => 'Matt', :last_name => 'Beedle'
        @contact2 = Contact.make :first_name => 'Benjamin', :last_name => 'Pochhammer'
      end

      should 'only return contacts whos first or last name match the supplied string' do
        assert_equal [@contact], Contact.name_like('Mat').to_a
        assert_equal [@contact2], Contact.name_like('Pochh').to_a
        assert_equal [@contact], Contact.name_like('Matt Bee').to_a
      end
    end
  end

  context "Instance" do
    setup do
      @contact = Contact.make_unsaved(:florian, :user => User.make(:annika))
      @user = User.make
    end
    
    should 'be able to get all comments including those for any associated leads' do
      @contact.save
      lead = Lead.make :contact => @contact
      comment = Comment.make :commentable => lead
      assert_includes @contact.comments_including_leads, comment
    end

    should 'be able to get fields in pipe deliminated format' do
      assert_equal @contact.deliminated('|', ['first_name', 'last_name']), "Florian|Behn"
    end

    should 'be assigned an identifier on creation' do
      assert @contact.identifier.nil?
      @contact.save
      assert @contact.identifier
    end

    should 'be assigned consecutive identifiers' do
      @contact.save
      assert_equal 1, @contact.identifier
      @contact2 = Contact.make_unsaved
      assert @contact2.identifier.nil?
      @contact2.save
      assert_equal 2, @contact2.reload.identifier
    end

    should 'validate uniqueness of email' do
      @contact.email = 'florian.behn@careermee.com'
      @contact.save
      c = Contact.make_unsaved(:florian, :email => @contact.email)
      refute_valid c
      assert c.errors[:email]
    end

    context 'activity logging' do
      setup do
        @contact.save
        @contact = Contact.get(@contact.id)
      end

      should 'log an activity when created' do
        assert_includes @contact.activities.map(&:action), 'Created'
      end

      should 'log an activity when updated' do
        @contact.update :first_name => 'test'
        assert_includes @contact.activities.map(&:action), 'Updated'
      end

      should 'not log an "update" activity when do_not_log is set' do
        @contact.update :first_name => 'test', :do_not_log => true
        refute_includes @contact.activities.map(&:action), 'Updated'
      end

      should 'not log an update activity when created' do
        assert_equal 1, @contact.activities.count
      end

      should 'log an activity when deleted' do
        @contact.destroy
        assert_includes @contact.activities.map(&:action), 'Deleted'
      end

      should 'log an activity when restored' do
        @contact.destroy
        @contact.activities.destroy!
        @contact = Contact.get(@contact.id)
        @contact.update :deleted_at => nil
        assert_includes @contact.activities.reload.map(&:action), 'Restored'
      end
    end

    should 'have full name' do
      assert_equal 'Florian Behn', @contact.full_name
    end

    context 'listing_name' do
      should 'return last name, then first name' do
        assert_equal 'Behn, Florian', @contact.listing_name
      end

      should 'have no comma if there is no first name' do
        @contact.first_name = nil
        assert_equal 'Behn', @contact.listing_name
      end
    end

    should 'alias full_name to name' do
      assert_equal @contact.name, @contact.full_name
    end

    should 'require last name' do
      @contact.last_name = nil
      refute_valid @contact
      assert @contact.errors[:last_name]
    end

    should 'be valid with all required attributes' do
      assert_valid @contact
    end
  end
end
