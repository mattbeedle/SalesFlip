require 'test_helper.rb'

class AttributeCleanerTest < ActiveSupport::TestCase
  setup do
    @model = DataMapper::Model.new do
      clean_attributes :name
      property :name, String
    end
  end

  should "work when passing nil" do
    assert_nothing_raised do
      @model.new(name: nil)
    end
  end

  should "remove leading spaces" do
    assert_equal "John", @model.new(name: " John").name
  end

  should "remove trailing spaces" do
    assert_equal "John", @model.new(name: "John\r\n\t ").name
  end

  should "remove leading single quotes" do
    assert_equal "John", @model.new(name: "'John").name
  end

  should "remove trailing single quotes" do
    assert_equal "John", @model.new(name: "John'").name
  end

  should "remove leading double quotes" do
    assert_equal "John", @model.new(name: '"John').name
  end

  should "remove trailing double quotes" do
    assert_equal "John", @model.new(name: 'John"').name
  end

  should "remove mixes of whitespace and quotes" do
    assert_equal "John", @model.new(name: %Q[\r'John  \t"]).name
  end
end
