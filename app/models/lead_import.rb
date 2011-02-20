class LeadImport
  include DataMapper::Resource
  include DataMapper::Timestamps
  include Assignable
  include HasConstant::Orm::DataMapper

  property :id, Serial
  property :deliminator, String, default: ','
  property :unimported, Object, default: []
  property :file, String, auto_validation: false
  property :file_filename, String
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_presence_of :deliminator, :user

  validates_presence_of :file
  mount_uploader :file, AttachmentUploader

  has_constant :states, %w(pending completed canceled),
    default: "pending"
  has_constant :sources, lambda { Lead.sources },
    default: "Imported"

  belongs_to :user

  has n, :imported, 'Lead', through: Resource

  def import
    lines.each_with_index do |line, index|

      if index == 0
        get_included_fields(line)
      else
        values = line.split(deliminator)
        lead = Lead.new(build_attributes(values))
        lead.last_name = 'n/a' if lead.last_name.blank?
        similar = lead.similar(0.9)
        similar_accounts = lead.similar_accounts(0.9)
        unless similar.any? || similar_accounts.any?
          if lead.save
            Sunspot.index!(lead)
            self.imported << lead
          end
        else
          self.unimported << [line, similar.map(&:id) + similar_accounts.map(&:id)]
        end
        save
      end
    end
    self.state = 'completed'
    save
    ImportMailer.import_summary(self).deliver
  end

  def lines
    file.read.encode('utf-8').split("\n")
  end

  def progress
    (total_imported.to_f / lines.count) * 100
  end

  def total_imported
    imported.count + unimported.count
  end

  protected

  def get_included_fields(line)
    @fields ||= line.split(deliminator).map do |field|
      field.downcase.gsub(/\s/, '_')
    end
  end

  def build_attributes(values)
    attributes = { :user => user, :source => self.source,
                   :assignee => assignee, :do_not_index => true,
                   :do_not_notify => true, :do_not_log => true }
    @fields.each_with_index do |field, i|
      value = values[i].blank? ? nil : values[i].gsub(/[\n"\r]/, '').strip
      attributes.merge!(field.gsub(/[\n"\r]/, '').strip.to_sym => value)
    end
    attributes
  end
end
