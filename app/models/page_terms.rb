class PageTerms < ActiveRecord::Base
  belongs_to :page

  define_index do
    begin
      ## text fields ##

      # general fields
      indexes :title,     :sortable => true
      indexes :page_type, :sortable => true
      indexes :tags
      indexes :body
      indexes :comments

      # denormalized names
      indexes :created_by_login, :sortable => true
      indexes :updated_by_login, :sortable => true
      indexes :group_name,       :sortable => true

      ## attributes ##

      # timedates
      has :page_created_at
      has :page_updated_at
      has :starts_at
      has :ends_at

      # ids
      has :created_by_id
      has :updated_by_id
      has :group_id

      # flags and access
      has :resolved
      has :access_ids, :type => :multi # multi: indexes as an array of ints

      # index options
      set_property :delta => true

    rescue
      RAILS_DEFAULT_LOGGER.warn "failed to index page #{self.id} for sphinx search"
    end
  end

  def updated_at=(value)
    page_updated_at = value
  end
  def created_at=(value)
    page_created_at = value
  end

end
