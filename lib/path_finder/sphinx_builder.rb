
=begin

Concrete subclass of Builder

This class calls the sphinx active record extension search_for_ids, or uses the Riddle plugin, if necessary.
It is called from find_by_path.rb

=end

class PathFinder::SphinxBuilder < PathFinder::Builder

  public

  def initialize(path, options)
    @args_for_find = {:conditions => " @user_id #{options[:user_id]} | @group_id #{options[:group_ids].join('|')} "}
#current_user.all_group_ids, current_user.id
    @path          = cleanup_path(path)
  end

  #
  # Here it is folks!! The main function that handles all the
  # page finding. It all starts here.
  #
  def find_pages
puts "applying filters from path"
    apply_filters_from_path( @path )

    y @args_for_find
#    @args_for_find[:conditions] = "test"
    Page.find Page.search_for_ids(@args_for_find)
  end

  def count_pages
    0
  end
  
  ######################################################################
  #### PRIVATE
  
end
