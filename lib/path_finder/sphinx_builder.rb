
=begin

Concrete subclass of Builder

This class calls the sphinx active record extension search_for_ids, or uses the Riddle plugin, if necessary.
It is called from find_by_path.rb

=end

class PathFinder::SphinxBuilder < PathFinder::Builder

  include PathFinder::SphinxBuilderFilters

  public

  # this builds the sphinx find conditions,
  # which limit the search results to pages
  # which are visible to the public, the current_user,
  # or the current group
  #
  # based on what is hashed into options
  #
  # TODO: replace this with a function which takes a user, and extracts
  # the entity information from that.  (is this sufficiently expressive?)
  def initialize(path, options)
    @args_for_find = { :conditions => {:entities => entities_str(options) }, :page => options[:page] }
    @search_text   = ""
    @path          = cleanup_path(path)
  end

  def find_pages
    apply_filters_from_path( @path )
    @args_for_find[:order] ||= "updated_at DESC"
    pages = PageIndex.search @search_text, @args_for_find.merge(:include => :page)

    # pages has all of the will_paginate magic included, it just needs to actually have the pages
    pages.each_with_index {|page_index, i| pages[i] = page_index.page if page_index}
  end

  ######################################################################
  #### PRIVATE
  private
  
  def entities_str(options)
    return @entities_str if @entities_str    

    entities = []
    entities << "public" if options[:public]
    entities << "user_#{options[:user_id]}" if options[:user_id]
    options[:group_ids].each { |gid| entities << "group_#{gid}" }
    @entities_str = entities.join(" | ")

    @entities_str = "( #{@entities_str} ) & group_#{options[:group_id]}" if options[:group_id]
    @entities_str = "( #{@entities_str} ) & user_#{options[:other_user_id]}" if options[:other_user_id]
    
    @entities_str
  end
end
