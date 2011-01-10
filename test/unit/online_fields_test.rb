require 'test_helper'

class OnlineFieldsClass
  include Mongoid::Document
end

class OnlineFieldsTest < ActiveSupport::TestCase
  context 'Class' do
    setup do
      OnlineFieldsClass.send(:include, OnlineFields)
    end

    should 'add website field' do
      assert OnlineFieldsClass.fields.map(&:first).include?('website')
    end

    should 'add twitter field' do
      assert OnlineFieldsClass.fields.map(&:first).include?('twitter')
    end

    should 'add linked_in field' do
      assert OnlineFieldsClass.fields.map(&:first).include?('linked_in')
    end

    should 'add facebook field' do
      assert OnlineFieldsClass.fields.map(&:first).include?('facebook')
    end

    should 'add xing field' do
      assert OnlineFieldsClass.fields.map(&:first).include?('xing')
    end

    should 'add blog field' do
      assert OnlineFieldsClass.fields.map(&:first).include?('blog')
    end
  end

  context 'Instance' do
    setup do
      OnlineFieldsClass.send(:include, OnlineFields)
    end

    should 'require the website to match /^http/' do
      model = OnlineFieldsClass.new :website => 'test.com'
      model.valid?
      assert_equal 'http://test.com', model.website
    end
  end
end
