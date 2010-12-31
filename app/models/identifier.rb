class Identifier
  include DataMapper::Resource

  property :id, Serial
  property :account_identifier, Integer, :default => 0, :required => true
  property :contact_identifier, Integer, :default => 0, :required => true
  property :lead_identifier, Integer, :default => 0, :required => true

  def self.next_account
    Identifier.create unless Identifier.count > 0
    identifier = first
    first.increment!(:account_identifier)
    first.account_identifier
  end

  def self.next_contact
    Identifier.create unless Identifier.count > 0
    identifier = first
    first.increment!(:contact_identifier)
    first.contact_identifier
  end

  def self.next_lead
    Identifier.create unless Identifier.count > 0
    identifier = first
    first.increment!(:lead_identifier)
    first.lead_identifier
  end

  def increment!( key )
    update key => self.send(key) + 1
  end
end
