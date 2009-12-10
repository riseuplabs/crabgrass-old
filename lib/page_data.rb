module PageData
  def self.included(base)
    # Use page_terms to find what objects the user has access to. Note that it is
    # necessary to match against both access_ids and tags, since the index only
    # works if both fields are included.
    base.named_scope :visible_to, lambda { |*args|
      access_filter = PageTerms.access_filter_for(*args)
      { :select => "#{base.table_name}.*", :joins => :page_terms,
        :conditions => ['MATCH(page_terms.access_ids,page_terms.tags) AGAINST (? IN BOOLEAN MODE)', access_filter]
      }
    }

    base.named_scope :most_recent, :order => 'updated_at DESC'

    base.named_scope :exclude_ids, lambda {|ids|
      if ids.any? and ids.is_a? Array
        {:conditions => ["#{base.table_name}.id NOT IN (?)", ids]}
      else
        {}
      end
    }

    # ruby has unexpected syntax for checking if Page is a superclass of base
    unless base <= Page
      base.has_many :pages, :as => :data
      base.belongs_to :page_terms
      base.class_eval do
        def page; pages.first; end
      end
    else
      # I do not think this is used, or would be very useful:
      #base.class_eval do
      #  def page; self; end
      #end
    end

    base.before_save :ensure_page_terms
  end

  public

  # allows user.may?(:view, asset)
  def visible?(user)
    page_terms.access_ids_include?(user)
  end

  protected

  def ensure_page_terms
    if self.page_terms.nil?
      self.page_terms = self.page.page_terms if self.page
    end
  end

end
