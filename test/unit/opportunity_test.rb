require 'test_helper'

class OpportunityTest < ActiveSupport::TestCase
  context 'Class' do
    should_have_key :title, :close_on, :probability, :amount, :discount,
      :background_info, :created_at, :updated_at, :margin
    should_belong_to :assignee, :user, :contact, :stage
    should_have_many :comments, :tasks, :attachments
    should_validate_presence_of :title, :user, :stage
    should_act_as_paranoid

    context 'assigned_to' do
      setup do
        @user = User.make :annika
        @user2 = User.make :benny
        @opportunity = Opportunity.make :assignee => @user
        @opportunity2 = Opportunity.make :assignee => @user2
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
        @opportunity = Opportunity.make :user => @user
        @opportunity2 = Opportunity.make :user => @user2
        @opportunity3 = Opportunity.make :user => @user3
      end

      should 'only return occupations belonging to users in the supplied company' do
        assert_equal [@opportunity, @opportunity3], Opportunity.for_company(@user.company).to_a
        assert_equal [@opportunity2], Opportunity.for_company(@user2.company).to_a
      end
    end

    context 'stage_is' do
      setup do
        stage = OpportunityStage.make(:name => 'prospecting')
        stage2 = OpportunityStage.make(:name => 'analysis')
        @opportunity = Opportunity.make :stage_id => stage.id
        @opportunity2 = Opportunity.make :stage_id => stage2.id
      end

      should 'only return opportunities with the corresponding stage' do
        assert_equal [@opportunity], Opportunity.stage_is('prospecting').to_a
        assert_equal [@opportunity2], Opportunity.stage_is('analysis').to_a
      end

      should 'work with arrays' do
        assert_equal 2, Opportunity.stage_is(['prospecting', 'analysis']).count
      end
    end

    context 'create_for' do
      setup do
        @contact = Contact.make
      end

      should 'create an opportunity from the supplied contact' do
        opportunity = Opportunity.create_for(@contact, :opportunity => { :title => 'An opportunity',
          :stage => OpportunityStage.first })
        assert_equal 1, Opportunity.count
        assert_equal 'An opportunity', Opportunity.first.title
      end

      should 'assign the opportunity to the supplied contact' do
        opportunity = Opportunity.create_for(@contact, :opportunity => { :title => 'An opportunity',
          :stage => OpportunityStage.first })
        assert_equal 1, @contact.opportunities.count
      end

      should 'not create the opportunity if the supplied contact is invalid' do
        opportunity = Opportunity.create_for(Contact.new, :opportunity => { :title => 'An opportunity',
          :stage => OpportunityStage.first })
        assert_equal 0, Opportunity.count
      end

      should 'not create the opportunity if the title is not supplied' do
        opportunity = Opportunity.create_for(@contact, :opportunity => { :stage =>
          OpportunityStage.first })
        assert_equal 0, Opportunity.count
        assert opportunity.errors.blank?
      end
    end

    context 'closing_between_dates' do
      setup do
        @opportunity = Opportunity.make :close_on => Date.today
        @opportunity2 = Opportunity.make :close_on => Date.today + 1.month
      end

      should 'only return opportunities closing between the supplied dates' do
        assert_equal [@opportunity], Opportunity.closing_between_dates(Date.today - 1.day,
                                                               Date.tomorrow).to_a
      end
    end

    context 'for_date' do
      setup do
        @opportunity = Opportunity.make
        @opportunity2 = Opportunity.make :close_on => Date.yesterday
      end

      should 'only return opportunities closing between the supplied dates' do
        assert_equal [@opportunity2], Opportunity.closing_for_date(Date.yesterday).to_a
      end
    end

    context 'certainty' do
      setup do
        @opportunity = Opportunity.make
        @opportunity2 = Opportunity.make :stage => OpportunityStage.make(:percentage => 100)
      end

      should 'only return opportunities with a probability of 100%' do
        assert_equal [@opportunity2], Opportunity.certainty.to_a
      end
    end

    context 'created_on' do
      setup do
        @opportunity = Opportunity.make
        Timecop.freeze(Date.yesterday) do
          @opportunity2 = Opportunity.make
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
      @opportunity = Opportunity.new
    end

    should 'update close date to the current date when the opportunity stage is set to 100%' do
      opportunity = Opportunity.make
      stage = OpportunityStage.make :percentage => 100
      assert opportunity.close_on != Date.today
      opportunity.update :stage => stage
      assert_equal Date.today, opportunity.close_on
    end

    should 'not update close date when the opportunity was already closed in the past' do
      opportunity = Opportunity.make :stage => OpportunityStage.make(:percentage => 100),
        :close_on => Date.yesterday
      assert_not_equal Date.today, opportunity.close_on
    end

    should 'take probability from associated stage' do
      opportunity = Opportunity.make
      stage = OpportunityStage.make :percentage => 57
      opportunity.update :stage => stage
      assert_equal 57, opportunity.probability
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
      @opportunity = Opportunity.make(:title => 'a title')
      assert_equal 'a title', @opportunity.name
    end

    context 'activity logging' do
      setup do
        @opportunity = Opportunity.make
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
        @opportunity.update :deleted_at => nil
        assert @opportunity.activities.any? {|a| a.action == 'Restored' }
      end
    end
  end
end
