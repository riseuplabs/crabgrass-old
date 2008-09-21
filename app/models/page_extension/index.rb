=begin

SPHINX FULLTEXT SEARCHING

Here in lies the code for supporting full text indexing of pages, to be
used by sphinx. See also lib/path_finder for how this is actually searched.

=end

module PageExtension::Index

  def self.included(base)
    base.extend(ClassMethods)
    base.instance_eval do
      has_one :page_terms, :dependent => :destroy
      before_save :update_page_terms_in_background
      include InstanceMethods
    end
  end

  module ClassMethods
    # returns the an array of group and user ids, but transformed.
    # this transformation is neccessary for sphinx (so that group ids
    # and user ids are in the same attribute) and for mysql fulltext
    # (where terms must be at least 4 characters long).
    # 
    # When stored in sphinx, these are converted to numbers. When stored
    # in mysql, these are stored as strings.
    #
    # for example:
    #   access_ids_for(:public => true, :group_ids => [1,2,3000], :user_ids => [4,5,6000])
    # returns:
    #   ["0001", "0081", "0082", "83000", "0014", "0015", "16000"]
    #
    def access_ids_for(args={})
      id_array = []
      id_array += ["0001"] if args[:public]
      id_array += args[:group_ids].collect {|id| "%04d" % "8#{id}"} if args[:group_ids]
      id_array += args[:user_ids].collect  {|id| "%04d" % "1#{id}"} if args[:user_ids]
      return id_array
    end

    # converts a tag list array into a tag list array suitable for searching
    # a fulltext index with (no spaces, at least four characters, prefix with _ if numeric).
    # example:
    #   ['blue fish', 'tv', '12', '1234'] => ['blue_fish', '__tv', '__12', '_1234']
    def searchable_tag_list(tags)
      tags.map do |s|
        ("%4s" % s).gsub(/\s|^(\d)/,'_\1')
      end
    end

    def with_deltas_disabled
      if block_given?
        previous_deltas_enabled = ThinkingSphinx.deltas_enabled?
        begin
          ThinkingSphinx.deltas_enabled = false
          yield
        ensure
          ThinkingSphinx.deltas_enabled = previous_deltas_enabled
        end
      end
    end 

  end 
    
  module InstanceMethods    
  
    def update_page_terms_in_background
      if ::BACKGROUND
        begin
          # first, immediately update access, because that needs to always be up to date.
          Page.with_deltas_disabled do 
            terms = (self.page_terms || self.create_page_terms)
            PageTerms.update_all("access_ids = '%s'" % self.access_ids, 'id = %i' % terms.id)
          end
          # fire off background task
          MiddleMan.worker(:indexing_worker).async_update_page_terms(:arg => self.id)
        rescue BackgrounDRb::NoServerAvailable => err
          logger.error "Warning: #{err}; performing synchronous update of page index"
          update_page_terms
        end
      else
        update_page_terms
      end
    end
  
    def update_page_terms
      terms = (self.page_terms ||= self.build_page_terms)

      # attributes
      %w[updated_at created_at starts_at ends_at created_by_id updated_by_id group_id
      created_by_login updated_by_login group_name resolved
      flow contributors_count].each do |field|
        terms.send("#{field}=",self.send(field))
      end

      # text
      terms.title     = title.capitalize + ' ' + tag_list.join(' ')
                      # ^^ start with capital letter for sorting
      terms.tags      = Page.searchable_tag_list(tag_list).join(' ')
      terms.body      = summary_terms + body_terms
      terms.comments  = comment_terms
      terms.page_type = type

      # access control
      terms.access_ids = access_ids
   
      # additional hook for subclasses
      custom_page_terms(terms)
      
      if !self.new_record? and terms.changed?
        terms.save!
      end
    end
    
    # :nodoc:
    def access_ids
      Page.access_ids_for(
        :public => public?,
        :group_ids => group_ids,
        :user_ids => user_ids
      ).join(' ')
    end

    # Returns the text to be included in teh body of the page index.
    # Subclasses of Page should override this method as appropriate.
    # For example WikiPage should return wiki.body, and TaskListPage
    # will merge all of the tasks associated with it.
    # Defaults to empty string.
    def body_terms
      ""
    end

    # Returns text that should be weighted low.
    # Defaults to all the comments, but can be overriden by the page subclass.    
    def comment_terms
      discussion ? discussion.posts * "\n" : ""
    end

    # Returns the text that should be included with the body in the page index.
    # Defaults to the page name, title, and summary.
    def summary_terms
      [name, title, summary] * "\n"
    end

    # to be overriden by subclasses
    def custom_page_terms(terms) end

  end
end
