# encoding: utf-8
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require "blueprints"

DataMapper.auto_migrate!

DatabaseCleaner.strategy = :transaction

FakeWeb.allow_net_connect = false
FakeWeb.register_uri(:post, 'http://localhost:8981/solr/update?wt=ruby', :body => '')

class Sunspot::Rails::StubSessionProxy::Search
  def results
    [].paginate
  end
end

Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
Minion.logger {}

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  def self.should_have_constant(*args)
    klass = self.name.gsub(/Test$/, '').constantize
    args.each do |arg|
      should "have_constant '#{arg}'" do
        assert_respond_to klass.new, arg.to_s.singularize
        assert_respond_to klass, arg.to_s
        assert_respond_to klass.new, "#{arg.to_s.singularize}_is?"
      end
    end
  end

  def self.should_act_as_paranoid
    klass = self.name.gsub(/Test$/, '').constantize
    should 'act as paranoid' do
      assert_respond_to klass.new, 'deleted_at'
      assert_respond_to klass, 'not_deleted'
      assert_respond_to klass, 'deleted'
      assert_blank klass.not_deleted
      assert_blank klass.deleted
      obj = klass.make
      assert_includes klass.not_deleted, obj
      obj.destroy
      assert obj.deleted_at
      assert_includes klass.deleted, obj
      assert_blank klass.not_deleted
    end
  end

  def self.should_be_trackable
    klass = self.name.gsub(/Test$/, '').constantize
    should 'be trackable' do
      assert_respond_to klass.new, 'tracker_ids'
      assert_respond_to klass.new, 'trackers'
      assert_respond_to klass.new, 'tracker_ids='
      assert_respond_to klass.new, 'tracked_by?'
      assert_respond_to klass.new, 'remove_tracker_ids='
      assert_respond_to klass, 'tracked_by'
    end
  end

  def self.should_have_key(*args)
    if args.first.is_a? Class
      klass = args.shift
    else
      klass = self.name.gsub(/Test$/, '').constantize
    end
    args.each do |arg|
      should "have_key '#{arg}'" do
        assert klass.properties.named?(arg)
      end
    end
  end

  def self.should_require_key(*args)
    klass = self.name.gsub(/Test$/, '').constantize
    args.each do |arg|
      should "require key '#{arg}'" do
        if relationship = klass.relationships[arg]
          key = relationship.child_key.first
        else
          key = klass.properties[arg]
        end
        obj = klass.new
        key.set(obj, nil)
        obj.valid?
        assert_present obj.errors[key.name],
          "expected error on #{key.name} but got: #{obj.errors.to_hash.inspect}"
      end
    end
  end

  def self.should_have_many(*args)
    klass = self.name.gsub(/Test$/, '').constantize
    args.each do |arg|
      should "have_many '#{arg}'" do
        has = false
        klass.relationships.each do |relationship|
          if relationship.name.to_s == arg.to_s && relationship.class.name =~ /OneToMany/ && relationship.max == Infinity
            break has = true
          end
        end
        assert has
      end
    end
  end

  def self.should_belong_to(*args)
    klass = args.first.is_a?(Class) ? args.shift : self.name.gsub(/Test$/, '').constantize
    args.each do |arg|
      should "belong_to '#{arg}'" do
        has = false
        klass.relationships.each do |relationship|
          if relationship.name.to_s == arg.to_s && relationship.class.name =~ /ManyToOne/
            break has = true
          end
        end
        assert has
      end
    end
  end

  def self.should_have_uploader(*args)
    klass = self.name.gsub(/Test$/, '').constantize
    args.each do |arg|
      should "have_uploader '#{arg}'" do
        assert_kind_of CarrierWave::Uploader::Base, klass.new.send(arg)
      end
    end
  end

  def self.should_have_instance_methods(*args)
    klass = self.name.gsub(/Test$/, '').constantize
    args.each do |arg|
      should "have instance method '#{arg}'" do
        assert_respond_to klass.new, arg
      end
    end
  end

  setup do
    Sham.reset
    ActionMailer::Base.deliveries.clear
  end

  setup do
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
  end

  setup do
    DataMapper::Repository.context << repository
  end

  teardown do
    DataMapper::Repository.context.pop
  end

  def assert_valid(model)
    assert model.valid?, "Expected #{model.class} to be valid, but got: #{model.errors.full_messages.join(", ")}"
  end

  def refute_valid(model)
    refute model.valid?, "Expected #{model.class} to be invalid, but was valid"
  end

  def assert_add_job_email_sent(posting)
    assert_sent_email do |email|
      email.subject == "Neue Stellenanzeige von #{posting.job.company_name}" and
      email.body    =~ /#{posting.job.position}/ and
      email.to.include? posting.board.api_email
    end
  end

  def assert_delete_job_email_sent(posting)
    assert_sent_email do |email|
      email.subject == "Löschen der Stellenanzeige #{posting.job.position} von #{posting.job.company_name}" and
      email.body =~ /#{posting.job.position}/ and email.to.include? posting.board.api_email
    end
  end
end
