#
# PathFinder::Sphinx::Builder
#
# Concrete subclass of PathFinder::Builder with support for sphinx as the backend.
#
# This code is called by find_by_path() in PathFinder::FindByPath
#
class PathFinder::Sphinx::Builder < PathFinder::Builder

  include PathFinder::Sphinx::BuilderFilters

  def initialize(path, options, klass)
    @original_path = path
    @original_options = options
    @klass = klass #What are we searching Pages or Posts?

    # filter on access_ids:
    @with = []
    if options[:group_ids] or options[:user_ids] or options[:public]
      @with << ['access_ids', Page.access_ids_for(
        :public => options[:public],
        :group_ids => options[:group_ids],
        :user_ids => options[:user_ids]
      )]
    end
    if options[:secondary_group_ids] or options[:secondary_user_ids]
      @with << ['access_ids', Page.access_ids_for(
        :group_ids => options[:secondary_group_ids],
        :user_ids => options[:secondary_user_ids]
      )]
    end
    if options[:site_ids]
      @with << ['access_ids', Page.access_ids_for(
        :site_ids => options[:site_ids]
      )]
    end

    @without      = {}
    @conditions   = {}
    @order        = ""
    @search_text  = ""
    @per_page    = options[:per_page] || SECTION_SIZE
    @page        = options[:page] || 1

    apply_filters_from_path( path )
    @order = nil unless @order.any?
  end

  def search
    # the default sort is '@relevance DESC', but this can create rather odd
    # results because you might get relevent pages from years ago. So, if there
    # is no explicit order set, we want to additionally sort by page_updated_at.
    if @order.nil?
      @sort_mode = :extended
      @order = "@relevance DESC, page_updated_at DESC"
    end

    # puts "PageTerms.search #{@search_text.inspect}, :with => #{@with.inspect}, :without => #{@without.inspect}, :conditions => #{@conditions.inspect}, :page => #{@page.inspect}, :per_page => #{@per_page.inspect}, :order => #{@order.inspect}, :include => :page"

    # 'with' is used to limit the query using an attribute.
    # 'conditions' is used to search for on specific fields in the fulltext index.
    # 'search_text' is used to search all the fulltext index.
    page_terms = PageTerms.search @search_text,
      :page => @page,   :per_page => @per_page,  :include => :page,
      :with => @with,   :without => @without,    :conditions => @conditions,
      :order => @order, :sort_mode => @sort_mode

    # page_terms has all of the will_paginate magic included, it just needs to
    # actually have the pages, which we supply with page_terms.replace(pages).
    pages = []
    page_terms.each do |pt|
      pages << pt.page unless pt.nil?
      # Why might pt be nil? If the PageTerms was destroyed but sphinx has
      # not been reindex. This should not ever happen when things are working,
      # but sometimes it does, and if it does we don't want to bomb out.
    end
    page_terms.replace(pages)
  end

  def find
    search
  rescue ThinkingSphinx::ConnectionError
    PathFinder::Mysql::Builder.new(@original_path, @original_options, @klass).find     # fall back to mysql
  end

  def paginate
    search # sphinx search *always* paginates
  rescue ThinkingSphinx::ConnectionError
    PathFinder::Mysql::Builder.new(@original_path, @original_options, @klass).paginate     # fall back to mysql
  end

  def count
    PageTerms.search_for_ids(@search_text, :with => @with, :without => @without,
      :conditions => @conditions, :page => @page, :per_page => @per_page,
      :order => @order, :include => :page).size
  rescue ThinkingSphinx::ConnectionError
    PathFinder::Mysql::Builder.new(@original_path, @original_options, @klass).count        # fall back to mysql
  end
end
