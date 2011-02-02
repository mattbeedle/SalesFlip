require 'test_helper.rb'

class CompanyTest < ActiveSupport::TestCase
  context 'Class' do
    should_have_key :name
    should_require_key :name
    should_have_many :users, :opportunity_stages
  end

  context 'Instance' do
    setup do
      @company = Company.make_unsaved(:jobboersen)
    end

    should 'validate uniqueness of name' do
      Company.make(:jobboersen)
      @company = Company.make_unsaved(:jobboersen)
      assert !@company.valid?
      assert @company.errors[:name]
    end

    should 'get default opportunity stages on creation' do
      company = Company.make
      I18n.t(:opportunity_stages).each do |stage|
        assert company.opportunity_stages.map(&:name).include?(stage)
      end
    end

    context 'caching' do
      setup do
        @company.save!
        @user = User.make :company => @company
      end

      Lead.statuses.each do |status|
        should "cache #{status} lead count" do
          Lead.make :user => @user, :status => status
          assert_equal 1, @company.reload.
            send("#{status.downcase.gsub(/[\s\-]/, '_')}_lead_count")
        end
      end

      should 'cache unassigned lead count' do
        Lead.make :user => @user
        assert_equal 1, @company.reload.unassigned_lead_count
      end

      Lead.sources.each do |source|
        should "cache #{source} lead count" do
          Lead.make :user => @user, :source => source
          assert_equal 1, @company.reload.
            send("#{source.downcase.gsub(/[\s\-]/, '_')}_lead_count")
        end
      end
    end
  end
end
