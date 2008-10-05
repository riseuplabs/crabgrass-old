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
      has :media, :type => :multi

      # index options
      set_property :delta => true

    rescue
      RAILS_DEFAULT_LOGGER.warn "failed to index page #{self.id} for sphinx search"
    end
  end

  def updated_at=(value)
    write_attribute(:page_updated_at, value)
  end
  def created_at=(value)
    write_attribute(:page_created_at, value)
  end

  # returns a string suitable for using in a fulltext match against
  # page_terms.access_ids. The args are any number of users or groups.
  # the filter will require all args have access.
  def self.access_filter_for(*args)
    filter_str = ""
    args.each do |arg|
      if arg.is_a? User
        user = arg
        access_ids = Page.access_ids_for(:user_ids => [user.id], :group_ids => user.group_ids)
      elsif arg.is_a? Group
        group = arg
        # include the ids of committees, but do not include networks
        access_ids = Page.access_ids_for(:group_ids => group.group_and_committee_ids)
      elsif arg == :public
        access_ids = Page.access_ids_for(:public => true)
      else 
        access_ids = nil
      end
      filter_str += " +(%s)" % access_ids.join(' ') if access_ids
    end
    filter_str
  end

end
