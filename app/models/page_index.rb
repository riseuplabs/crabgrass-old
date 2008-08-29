class PageIndex < ActiveRecord::Base
  belongs_to :page

  define_index do
    begin
      indexes :title, :sortable => true
 
      indexes :body
      indexes :class_display_name, :sortable => true
      indexes :tags
      indexes :entities
      
      has :resolved
      
      has :page_created_at, :as => :created_at
      has :page_created_by_id, :as => :created_by_id
      has :page_created_by_login, :as => :created_by_login
      has :page_updated_at, :as => :updated_at
      has :page_updated_by_login, :as => :updated_by_login
      has :group_name, :sortable => true
      has :starts_at
    
      set_property :delta => true
# TODO: figure out if this exception handling is slowing down saving or indexing
    rescue
      RAILS_DEFAULT_LOGGER.warn "failed to index page #{self.id} for sphinx search"
    end
  end

end
