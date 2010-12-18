require 'test_helper'

class OpportunityStageTest < ActiveSupport::TestCase
  context 'Class' do
    should_have_key :name, :percentage, :notes
    should_belong_to :company
    should_have_many :opportunities
    should_require_key :name, :percentage
    should_act_as_paranoid
  end

  context 'Instance' do
    setup do
      @opportunity_stage = OpportunityStage.make_unsaved
    end

    should 'not be valid if the percentage is not a number' do
      @opportunity_stage.percentage = 'asdf'
      assert !@opportunity_stage.valid?
      assert @opportunity_stage.errors[:percentage]
    end
  end
end
