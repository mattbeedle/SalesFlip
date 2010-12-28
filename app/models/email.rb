class Email < Comment
  property :received_at, Time, :required => true
  property :from, String, :required => true

  # validates_presence_of :subject

  alias :name :subject
end
