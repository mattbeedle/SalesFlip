require 'test_helper'

class OpportunityTest < ActiveSupport::TestCase
  context 'Class' do
    should_have_key :title, :close_on, :probability, :amount, :discount,
      :background_info, :created_at, :updated_at, :margin
    should_belong_to :assignee, :user, :contact
    should_have_many :comments, :tasks, :attachments
    should_require_key :title, :user, :stage

    setup do
      @contact = Contact.make
      @annika = User.make :annika
    end

    context 'assigned_to' do
      setup do
        @user = User.make :annika
        @user2 = User.make :benny
        @opportunity = Opportunity.make :assignee => @user, :contact => @contact
        @opportunity2 = Opportunity.make :assignee => @user2, :contact => @contact
      end

      should 'only return opportunities assigned to the specified user id' do
        assert_equal [@opportunity], Opportunity.assigned_to(@user.id).to_a
        assert_equal [@opportunity2], Opportunity.assigned_to(@user2.id).to_a
      end

      should 'work with string ids' do
        assert_equal [@opportunity], Opportunity.assigned_to(@user.id.to_s).to_a
      end
    end

    context 'for_company' do
      setup do
        @user = User.make :annika
        @user2 = User.make :benny
        @user3 = User.make :company => @user.company
        @opportunity = Opportunity.make :user => @user, :contact => @contact
        @opportunity2 = Opportunity.make :user => @user2, :contact => @contact
        @opportunity3 = Opportunity.make :user => @user3, :contact => @contact
      end

      should 'only return occupations belonging to users in the supplied company' do
        assert_equal [@opportunity, @opportunity3], Opportunity.for_company(@user.company).to_a
        assert_equal [@opportunity2], Opportunity.for_company(@user2.company).to_a
      end
    end

    context 'create_for' do
      setup do
        Opportunity.destroy
        @contact = Contact.make
      end

      should 'create an opportunity from the supplied contact' do
        opportunity = Opportunity.create_for(@contact, :opportunity => { :title => 'An opportunity', :budget => 2000, stage: 'New' })
        assert_equal 1, Opportunity.count
        assert_equal 'An opportunity', Opportunity.first.title
      end

      should 'assign the opportunity to the supplied contact' do
        opportunity = Opportunity.create_for(@contact, :opportunity => { :title => 'An opportunity', :budget => 2000, stage: 'New' })
        assert_equal 1, @contact.opportunities.count
      end

      should 'not create the opportunity if the supplied contact is invalid' do
        opportunity = Opportunity.create_for(Contact.new, :opportunity => { :title => 'An opportunity',
          :budget => 2000 })
        assert_equal 0, Opportunity.count
      end

      should 'not create the opportunity if the title is not supplied' do
        opportunity = Opportunity.create_for(@contact, :opportunity => { :budget => 2000 })
        assert_equal 0, Opportunity.count
      end
    end

    context 'closing_between_dates' do
      setup do
        @opportunity = Opportunity.make :close_on => Date.today, :contact => @contact
        @opportunity2 = Opportunity.make :close_on => Date.today + 1.month, :contact => @contact
      end

      should 'only return opportunities closing between the supplied dates' do
        assert_equal [@opportunity], Opportunity.closing_between_dates(Date.today - 1.day,
                                                               Date.tomorrow).to_a
      end
    end

    context 'for_date' do
      setup do
        @opportunity = Opportunity.make :contact => @contact
        @opportunity2 = Opportunity.make :close_on => Date.yesterday, :contact => @contact
      end

      should 'only return opportunities closing between the supplied dates' do
        assert_equal [@opportunity2], Opportunity.closing_for_date(Date.yesterday).to_a
      end
    end

    context 'certainty' do
      setup do
        @opportunity = Opportunity.make :contact => @contact
        @opportunity2 = Opportunity.make(
          :contact => @contact,
          :stage => 'Closed / Won'
        )
      end

      should 'only return opportunities with a probability of 100%' do
        assert_equal [@opportunity2], Opportunity.certainty.to_a
      end
    end

    context 'created_on' do
      setup do
        @opportunity = Opportunity.make(:contact => @contact)
        Timecop.freeze(Date.yesterday) do
          @opportunity2 = Opportunity.make(:contact => @contact)
        end
      end

      should 'only return opportunities created on the supplied date' do
        assert_equal [@opportunity2], Opportunity.created_on(Date.yesterday).to_a
        assert_equal [@opportunity], Opportunity.created_on(Date.today).to_a
      end
    end
  end

  context 'Instance' do
    setup do
      Minion.stubs(:enqueue)
      @contact = Contact.make
      @opportunity = Opportunity.new
    end

    context "#outbound_update!" do

      context "when the status is new" do

        setup do
          @opportunity = Opportunity.make_unsaved(stage: 'New', contact: @contact)
          @opportunity.save
        end

        should "change status to offer requested" do
          assert_equal "Offer Requested", 'Offer Requested'
        end
      end
    end

    should 'only allow numbers for "amount"' do
      @opportunity.amount = 'asdfewf'
      @opportunity.valid?
      assert @opportunity.errors[:amount]
      @opportunity.amount = 123
      @opportunity.valid?
      assert @opportunity.errors[:amount].blank?
    end

    should 'only allow numbers for "discount"' do
      @opportunity.discount = 'asdfewf'
      @opportunity.valid?
      assert @opportunity.errors[:discount]
      @opportunity.discount = 123
      @opportunity.valid?
      assert @opportunity.errors[:discount].blank?
    end

    should 'only allow numbers for "probability"' do
      @opportunity.probability = 'asdfewf'
      @opportunity.valid?
      assert @opportunity.errors[:probability]
      @opportunity.probability = 123
      @opportunity.valid?
      assert @opportunity.errors[:probability].blank?
    end

    should 'update close date to the current date when the opportunity stage is set to 100%' do
      opportunity = Opportunity.make(contact: @contact)
      assert opportunity.close_on != Date.today
      opportunity.update :stage => 'Closed / Won'
      assert_equal Date.today, opportunity.close_on
    end

    should 'not update close date when the opportunity was already closed in the past' do
      opportunity = Opportunity.make :stage => 'Closed / Won',
        :close_on => Date.yesterday, :contact => @contact
      assert_not_equal Date.today, opportunity.close_on
    end

    should 'take probability from associated stage' do
      opportunity = Opportunity.make :contact => @contact
      opportunity.update :stage => 'Offer Sent'
      assert_equal 50, opportunity.probability
    end

    should 'calculate the weighted amount based on the amount, the discount and the probability' do
      @opportunity.attributes = { :amount => 200, :probability => 90 }
      assert_equal 180, @opportunity.weighted_amount
      @opportunity.attributes = { :amount => 1000, :discount => 500, :probability => 10 }
      assert_equal 50, @opportunity.weighted_amount
    end

    should 'default close_on to 1 month from now' do
      assert_equal Date.parse(1.month.from_now.to_s), @opportunity.close_on
    end

    should 'alias title to name' do
      @opportunity = Opportunity.new(:title => 'a title')
      assert_equal 'a title', @opportunity.name
    end

    context 'activity logging' do
      setup do
        @opportunity = Opportunity.make(:contact => @contact)
      end

      should 'log an activity when created' do
        assert @opportunity.activities.any? {|a| a.action == 'Created' }
      end

      should 'log an activity when updated' do
        @opportunity.update :name => 'an update test'
        assert_equal 2, @opportunity.activities.count
        assert @opportunity.activities.any? {|a| a.action == 'Updated' }
      end

      should 'not log an update activity when created' do
        assert_equal 1, @opportunity.activities.length
      end

      should 'log an activity when deleted' do
        @opportunity.destroy
        assert @opportunity.activities.any? {|a| a.action == 'Deleted' }
      end

      should 'log an activity when restored' do
        @opportunity.destroy
        @opportunity = Opportunity.last
        @opportunity.reload.update :deleted_at => nil
        assert @opportunity.activities.any? { |a| a.action == 'Restored' }
      end
    end
  end
end
