require 'test_helper'

class OnlineFieldsClass
  include DataMapper::Resource
end

class OnlineFieldsTest < ActiveSupport::TestCase
  context 'Class' do
    setup do
      OnlineFieldsClass.send(:include, OnlineFields)
    end

    should 'add website field' do
      assert OnlineFieldsClass.properties.named?(:website)
    end

    should 'add twitter field' do
      assert OnlineFieldsClass.properties.named?(:twitter)
    end

    should 'add linked_in field' do
      assert OnlineFieldsClass.properties.named?(:linked_in)
    end

    should 'add facebook field' do
      assert OnlineFieldsClass.properties.named?(:facebook)
    end

    should 'add xing field' do
      assert OnlineFieldsClass.properties.named?(:xing)
    end

    should 'add blog field' do
      assert OnlineFieldsClass.properties.named?(:blog)
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
