#
# Routing in rails is a mysterious black box of insanity. Few who tread into
# its depths return to tell the tale. The meta-programming has meta-programming.
#
# Unfortunately, this block box has some serious problems when it comes to 
# crabgrass. 
#
# (1) globbing in routes messes up rails route recognition. It sometimes work
# but then will fail for other routes. If you write a test for it using
# assert_recognizes, the tests all pass. But when you run the code in the server, 
# it breaks. It is a nightmare. 
#
# For example:
#
#   map.connect 'groups/:action/:id/*path',
#     :controller => 'groups',
#     :action => /search/
#
#   url_for(:controller => 'groups', :action => 'search',
#     :id => 'rainbow', :path => ['ascending','title'])
# 
#   => /groups/search/animals?path[]=ascending&path[]=title
#
# (2) we really want to be able to do /groupname and /username urls. This is
# very nice and pretty and easy to remember. However, different controllers
# need to be called depending on what type of object is at /name.
#
# The code here in this file is a wrapper around the black box of rails routing.
# In effect, we have wrapped our own black box around the rails black box. 
#
# Our wrapper simply overrides the behavior of rails so that the routing code
# appears to the rest of the application to work like we want it to.
#
# This relies on Sven Fuchs awesome routing-filter plugin:
# http://github.com/svenfuchs/routing-filter/tree/master
#
class RoutingFilter::CrabgrassRoutingFilter < RoutingFilter::Base

  # uri => hash
  def around_recognize(route, path, &block)
    # Alter the path here before it gets recognized. 
    # Make sure to yield (calls the next around filter if present and 
    # eventually `recognize_path` on the routeset):
    returning yield do |params|
      # You can additionally modify the params here before they get passed
      # to the controller.
    end
  end

  # hash => uri
  def around_generate(controller, *args, &block)
    # Alter arguments here before they are passed to `url_for`. 
    # Make sure to yield (calls the next around filter if present and 
    # eventually `url_for` on the controller):

    returning yield do |result|
      # You can change the generated url_or_path here. Make sure to use
      # one of the "in-place" modifying String methods though (like sub! 
      # and friends).
      if result.is_a? String
        fix_globbed_path(result)
      end
    end
  end

  private

  #
  # often, rails will fail mysteriously to generate globbed paths.
  # maddeningly, it works perfectly well in tests.
  #
  # this hack takes a url of the form:
  #
  #   /groups/search/animals?path[]=type&path[]=text
  # 
  # and converts it into:
  #
  #   /groups/search/animals/type/text
  #
  # both will work, but the latter is a tad more attractive!
  #
  # this hack only works if the glob part is called 'path', like:
  #  
  #   map.connect 'person/:action/:id/*path', :controller => 'person'
  #
  QUERY_RE = /\?.*$/
  PATH_SPLIT_RE = /[\?&]path%5B%5D=/
  def fix_globbed_path(url)
    url.gsub!(QUERY_RE) do |query|
      new_query = []
      new_path = ['']
      query = query[1..-1] # remove leading '?'
      query.split(/&/).each do |segment|
        if segment =~ /^path%5B%5D=(.*)/
          new_path << $1
        else
          new_query << segment if segment.any?
        end
      end

      [new_path.join('/'), ('?' if new_query.any?), new_query.join('&')].join
    end
  end

end


