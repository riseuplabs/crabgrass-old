
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
    entities = []
    entities << "public" if options[:public]
    entities << "user_#{options[:user_id]}" if options[:user_id]
    options[:group_ids].each { |gid| entities << "group_#{gid}" }
    entity_str = entities.join(" | ")

    entity_str = "( #{entity_str} ) & group_#{options[:group_id]}" if options[:group_id]

    @args_for_find = { :conditions => {:entities => entity_str } }
    
    @search_text = ""

    @path          = cleanup_path(path)
  end

  #
  # Here it is folks!! The main function that handles all the
  # page finding. It all starts here.
  #
  def find_pages
#puts "applying filters from path"
    apply_filters_from_path( @path )
#    RAILS_DEFAULT_LOGGER.debug @args_for_find.to_yaml
#    @args_for_find[:conditions] = "test"
#require 'ruby-debug'; debugger
    @args_for_find[:per_page] ||= 1000
    Page.search @search_text, @args_for_find
  end

  def count_pages
    0
  end
  
  ######################################################################
  #### PRIVATE
  
end
