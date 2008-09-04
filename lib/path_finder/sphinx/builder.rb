
=begin

Concrete subclass of Builder

This class calls the sphinx active record extension search_for_ids, or uses the Riddle plugin, if necessary.
It is called from find_by_path.rb

=end

class PathFinder::Sphinx::Builder < PathFinder::Builder

  include PathFinder::Sphinx::BuilderFilters

  private
  
  # :nodoc:
  # every time we reference @with[:access_ids] we want to create
  # a unique key like :access_ids_X where X is a number.
  # This will allow us to create multiple filters on the same attribute
  # because of a hack to the thinking sphinx code we added in search.rb
  def access_ids_key
    @access_ids_key_count ||= 0
    @access_ids_key_count += 1
    "access_ids_#{@access_ids_key_count}".to_sym 
  end

  public

  def initialize(path, options)
    @with = {}
    if options[:group_ids] or options[:user_ids] or options[:public]
      @with[access_ids_key] = Page.access_ids_for(
        :public => options[:public],
        :group_ids => options[:group_ids],
        :user_ids => options[:user_ids]
      )
    end
    if options[:secondary_group_ids] or options[:secondary_user_ids]
      @with[access_ids_key] = Page.access_ids_for(
        :group_ids => options[:secondary_group_ids],
        :user_ids => options[:secondary_user_ids]
      )
    end
    @without      = {}
    @conditions   = {}
    @order        = ""
    @search_text  = ""
    @path         = cleanup_path(path)   
    @per_page    = options[:per_page] || SECTION_SIZE
    @page        = options[:page] || 1

    apply_filters_from_path( @path )
    @order = "page_updated_at DESC" unless @order.any?
  end

  def find
    # puts "PageTerms.search #{@search_text.inspect}, :with => #{@with.inspect}, :without => #{@without.inspect}, :conditions => #{@conditions.inspect}, :page => #{@page.inspect}, :per_page => #{@per_page.inspect}, :order => #{@order.inspect}, :include => :page"

    page_terms = PageTerms.search @search_text, :with => @with, :without => @without, 
      :conditions => @conditions, :page => @page, :per_page => @per_page,
      :order => @order, :include => :page

    # page_terms has all of the will_paginate magic included, it just needs to actually have the pages
    page_terms.each_with_index {|pt, i| page_terms[i] = pt.page if pt}
  end

  def paginate
    find # sphinx search *always* paginates
  end

  def count
    PageTerms.search_for_ids(@search_text, :with => @with, :without => @without, 
      :conditions => @conditions, :page => @page, :per_page => @per_page,
      :order => @order, :include => :page).size
  end


end
