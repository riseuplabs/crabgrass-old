=begin

Some notes on PageTerms
-----------------------

See PageExtension::Index for most the code dealing with PageTerms.

PageTerms holds searching information for a page. Every Page has exactly one
PageTerms object and vice-versa.

PageTerms has three uses:

(1) Sphinx full-text searching

In order to index for sphinx, we need to be able to run a sql query without ruby
logic. The page_terms table holds a copy of all the stuff we want to index for a
particular page. It turns out that this is 100 times faster to keep a copy of
this stuff in one table than trying to do complex queries on a sphinx reindex.

(2) Page permissions

PageTerms is also used to filter by access restrictions in non-sphinx page
queries. We could just use sphinx for all queries, but the problem with this is
that there are many situations in which the sphinx index could be out of date.

The page_terms table is a MyISAM table that has a fulltext index on
(access_ids, tag_ids). It must be MyISAM for fulltext index. It is important
to note that the fulltext index is a compound index and will ONLY work if BOTH
columns are matched against in the query. This is very important!

(3) Permissions for stuff that inherits page permissions

Sometimes you want to search directly on a thing, without having to go through
Page to get at the thing. For example, search directly for assets or tasks. But
you also only want to return results for pages that the user has access to. In
these cases, these tables hold a reference to page_terms and then the query just
joins in the page_terms table and does a match against (access_ids, tag_ids) like
in a normal page query.

=end

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
      indexes :owner_name,       :sortable => true

      ## attributes ##

      # timedates
      has :page_created_at
      has :page_updated_at
      has :views_count

      # ids
      has :created_by_id
      has :updated_by_id

      # flags and access
      has :resolved
      has :stars_count
      has :access_ids, :type => :multi # multi: indexes as an array of ints
      has :media, :type => :multi

      # index options
      set_property :delta => true
      set_property :field_weights => {:tags => 12, :title => 8, :body => 4, :comments => 2}
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

  # return nil if the object does not have an id in the access_ids string.
  # otherwise, returns a number
  def access_ids_include?(*args)
    hash = {}
    args.each do |object|
      if object.is_a? User
        hash[:user_ids] ||= []
        hash[:user_ids] << object.id
      elsif object.is_a? Group
        hash[:group_ids] ||= []
        hash[:group_ids] << object.id
      elsif object == :public
        hash[:public] = true
      end
    end
    id = Page.access_ids_for(hash).first
    return self.access_ids =~ /(^| )#{id}( |$)/
  end

  # returns a string suitable for using in a fulltext match against
  # page_terms.access_ids. The args are any number of users or groups or :public.
  # the filter will require that all args match.
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
