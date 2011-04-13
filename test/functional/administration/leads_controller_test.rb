require 'test_helper'

class Administration::LeadsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    sign_in User.make(:matt)
  end

  context 'reassigning leads' do
    should 'change the assignee' do
      user = User.make
      lead = Lead.make

      put :assignee, :leads => [lead.id], :assignee_id => user.id

      assert_equal user, lead.reload.assignee
    end

    should 'reassign scheduled tasks' do
      user = User.make
      lead = Lead.make
      task = Task.make(asset: lead, assignee: lead.assignee)

      put :assignee, :leads => [lead.id], :assignee_id => user.id

      assert_equal task.assignee, lead.reload.assignee
    end

    should 'not reassign completed tasks' do
      user = User.make
      lead = Lead.make
      task = Task.make(asset: lead, assignee: lead.assignee, completed_at: Time.now)

      put :assignee, :leads => [lead.id], :assignee_id => user.id

      refute_equal task.assignee, lead.reload.assignee
    end
  end

end
