require 'test_helper.rb'

class ActivityTest < ActiveSupport::TestCase
  context 'Class' do
    should_have_constant :actions
    should_require_key :creator_id

    context 'log' do
      setup do
        @lead = Lead.make(:erich)
        Activity.all.destroy
      end

      should 'create a new activity with the supplied user, model and action' do
        Activity.log(@lead.user, @lead, 'Viewed')
        assert_equal 1, Activity.count
        assert Activity.first(:user => @lead.user, :lead => @lead, :action => 'Viewed')
      end

      should 'create a new activity for "Deleted"' do
        Activity.log(@lead.user, @lead, 'Deleted')
        assert @lead.activities.any? {|a| a.action == 'Deleted' }
      end

      should 'work in de locale' do
        I18n.in_locale(:de) do
          Activity.log(@lead.user, @lead, 'Viewed')
        end
        assert Activity.where(:creator_id => @lead.user_id,
                              :lead_id => @lead.id,
                              :action => 'Viewed').first
      end

      should 'find and update the last activity if action is "Viewed"' do
        Activity.log(@lead.user, @lead, 'Viewed')
        activity = Activity.last
        updated_at = activity.updated_at
        sleep 1
        activity2 = Activity.log(@lead.user, @lead, 'Viewed')
        assert_equal 1, Activity.count
        assert updated_at != activity2.updated_at
      end

      should 'find and update the last activity if action is "Commented"' do
        Activity.log(@lead.user, @lead, 'Commented')
        activity = Activity.last
        updated_at = activity.updated_at
        sleep 1
        activity2 = Activity.log(@lead.user, @lead, 'Commented')
        assert_equal 1, Activity.count
        assert updated_at != activity2.updated_at
      end

      should 'find and update the last activity if action is "Updated"' do
        Activity.log(@lead.user, @lead, 'Updated')
        activity = Activity.last
        updated_at = activity.updated_at
        sleep 1
        activity2 = Activity.log(@lead.user, @lead, 'Updated')
        assert_equal 1, Activity.count
        assert updated_at != activity2.updated_at
      end

      should 'NOT create "Viewed" activity for tasks' do
        task = Task.make(:call_erich)
        Activity.all.destroy
        Activity.log(task.user, task, 'Viewed')
        assert_equal 0, Activity.count
      end
    end
  end

  context 'Named Scopes' do
    context 'already_notified' do
      setup do
        @user = User.make(:annika)
        @lead = Lead.make(:erich)
        @contact = Contact.make(:florian)
        Activity.all.destroy
        @activity1 = Activity.log(@user, @lead, 'Created')
        @activity2 = Activity.log(@user, @contact, 'Created')
        @activity2.update :notified_user_ids => [@user.id]
      end

      should 'return activities where the supplied user has already been notified' do
        assert_includes Activity.already_notified(@user), @activity2
        refute_includes Activity.already_notified(@user), @activity
        assert_equal 1, Activity.already_notified(@user).count
      end
    end

    context 'not_notified' do
      setup do
        @user = User.make(:annika)
        @lead = Lead.make(:erich)
        @contact = Contact.make(:florian)
        Activity.all.destroy
        @activity1 = Activity.log(@user, @lead, 'Created')
        @activity2 = Activity.log(@user, @contact, 'Created')
        @activity2.update :notified_user_ids => [@user.id]
      end

      should 'return activities where the supplied user needs to be notified' do
        assert_includes Activity.not_notified(@user), @activity1
        refute_includes Activity.not_notified(@user), @activity2
        assert_equal 1, Activity.not_notified(@user).count
      end
    end

    context 'not_restored' do
      setup do
        @deleted = Lead.make
        @deleted.destroy
        @restored = Lead.make
        @restored.destroy
        @restored = Lead.get(@restored.id)
        @restored.update :deleted_at => nil
      end

      should 'only return activities where the subject deleted_at is not nil' do
        assert_equal 1, Activity.action_is('Deleted').not_restored.count
        assert_includes Activity.not_restored.map(&:subject), @deleted
      end
    end

  end
end
