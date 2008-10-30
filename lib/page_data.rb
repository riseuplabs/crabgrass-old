module PageData
  def self.included(base)
    # Use page_terms to find what assets the user has access to. Note that it is
    # necessary to match against both access_ids and tags, since the index only
    # works if both fields are included.
    # FIXME: as far as I can tell page_terms never gets set in the first place,
    # as an asset is always associated with an AssetPage. Polymorphic associations
    # might work in this case, but I'm not sure if that will break anything else.
    #  --niklas
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

    base.has_many :pages, :as => :data
    base.belongs_to :page_terms
    base.class_eval do
      def page; pages.first; end
    end

  end
end