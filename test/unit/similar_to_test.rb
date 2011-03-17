require 'test_helper.rb'

class SimilarToTest < ActiveSupport::TestCase

  def refute_similar(reference, target)
    lead = Lead.create! company: target, user_id: 1, last_name: "Doe"
    refute_includes Lead.similar_to(Lead.new(company: reference)), lead
  end

  def assert_similar(reference, target)
    lead = Lead.create! company: target, user_id: 1, last_name: "Doe"
    assert_includes Lead.similar_to(Lead.new(company: reference)), lead
  end

  should "find identically named leads" do
    assert_similar "DATEV", "DATEV"
  end

  should "find identical leads with capitalization changes" do
    assert_similar "dAtEv", "DATEV"
  end

  context "with GmbH" do

    should "find leads with GmbH in the database" do
      assert_similar "Holy Fashion Group", "Holy Fashion Group GmbH"
    end

    should "find leads with GmbH on the client" do
      assert_similar "Holy Fashion Group GmbH", "Holy Fashion Group"
    end

  end

  context "with AG" do

    should "find leads with AG in the database" do
      assert_similar "Holy Fashion Group", "Holy Fashion Group AG"
    end

    should "find leads with AG on the client" do
      assert_similar "Holy Fashion Group AG", "Holy Fashion Group"
    end

  end

  context "with Gmbh AG Co. AG" do

    should "find leads with Gmbh AG Co. AG in the database" do
      assert_similar "Holy Fashion Group", "Holy Fashion Group Gmbh AG Co. AG"
    end

    should "find leads with Gmbh AG Co. AG on the client" do
      assert_similar "Holy Fashion Group Gmbh AG Co. AG", "Holy Fashion Group"
    end

  end

  context "with mbH" do

    should "find leads with mbH in the database" do
      assert_similar "Holy Fashion Group", "Holy Fashion Group mbH"
    end

    should "find leads with mbH on the client" do
      assert_similar "Holy Fashion Group mbH", "Holy Fashion Group"
    end

  end

  context "with KG" do

    should "find leads with KG in the database" do
      assert_similar "Holy Fashion Group", "Holy Fashion Group KG"
    end

    should "find leads with KG on the client" do
      assert_similar "Holy Fashion Group KG", "Holy Fashion Group"
    end

  end

  context "with KgaA" do

    should "find leads with KgaA in the database" do
      assert_similar "Holy Fashion Group", "Holy Fashion Group KgaA"
    end

    should "find leads with KgaA on the client" do
      assert_similar "Holy Fashion Group KgaA", "Holy Fashion Group"
    end

  end

  context "with eG" do

    should "find leads with eG in the database" do
      assert_similar "Holy Fashion Group", "Holy Fashion Group eG"
    end

    should "find leads with eG on the client" do
      assert_similar "Holy Fashion Group eG", "Holy Fashion Group"
    end

  end

  context "with eV" do

    should "find leads with eV in the database" do
      assert_similar "Holy Fashion Group", "Holy Fashion Group eV"
    end

    should "find leads with eV on the client" do
      assert_similar "Holy Fashion Group eV", "Holy Fashion Group"
    end

  end

  context "with E.G." do

    should "find leads with E.G. in the database" do
      assert_similar "Holy Fashion Group", "Holy Fashion Group E.G."
    end

    should "find leads with E.G. on the client" do
      assert_similar "Holy Fashion Group E.G.", "Holy Fashion Group"
    end

  end

  context "with e.V." do

    should "find leads with e.V. in the database" do
      assert_similar "Holy Fashion Group", "Holy Fashion Group e.V."
    end

    should "find leads with e.V. on the client" do
      assert_similar "Holy Fashion Group e.V.", "Holy Fashion Group"
    end

  end

  should "not get mixed up when the company name starts with a prefix" do
    refute_similar "E.G. Testing", "E.G.O. Control Systems GmbH"
  end

end
