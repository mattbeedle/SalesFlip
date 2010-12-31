# encoding: utf-8
ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require File.expand_path(File.dirname(__FILE__) + "/blueprints")

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
    klass = self.name.gsub(/Test$/, '').constantize
    args.each do |arg|
      should "have_key '#{arg}'" do
        assert klass.properties.named?(arg)
      end
    end
  end

  def self.should_require_key(*args)
    klass = self.name.gsub(/Test$/, '').constantize
    args.each do |arg|
      key = klass.relationships.has_key?(arg) ? :"#{arg}_id" : arg
      should "require key '#{arg}'" do
        obj = klass.new
        obj.send("#{key}=", nil)
        obj.valid?
        assert_present obj.errors[key], "expected error on #{key} but got: #{obj.errors.to_hash.inspect}"
      end
    end
  end

  def self.should_have_many(*args)
    klass = self.name.gsub(/Test$/, '').constantize
    args.each do |arg|
      should "have_many '#{arg}'" do
        has = false
        klass.relationships.each do |name, relationship|
          if name == arg.to_s && relationship.class.name =~ /OneToMany/ && relationship.max == Infinity
            break has = true
          end
        end
        assert has
      end
    end
  end

  def self.should_have_one(*args)
    klass = self.name.gsub(/Test$/, '').constantize
    args.each do |arg|
      should "have_one '#{arg}'" do
        has = false
        klass.associations.each do |name, assoc|
          if assoc.association.to_s.match(/ReferencesOne/) and name == arg.to_s
            has = true
          end
        end
        assert has
      end
    end
  end

  def self.should_belong_to(*args)
    klass = self.name.gsub(/Test$/, '').constantize
    args.each do |arg|
      should "belong_to '#{arg}'" do
        has = false
        klass.relationships.each do |name, relationship|
          if name == arg.to_s && relationship.class.name =~ /ManyToOne/
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
        assert_instance_of CarrierWave::Uploader::Base, klass.new.send(arg)
      end
    end
  end

  setup do
    DataMapper.auto_migrate!
    Sham.reset
    FakeWeb.allow_net_connect = false
    ActionMailer::Base.deliveries.clear
    FakeWeb.register_uri(:post, 'http://localhost:8981/solr/update?wt=ruby', :body => '')
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
