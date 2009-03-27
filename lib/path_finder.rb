# :include:path_finder/README
module PathFinder

  #  this works, but seems like overkill:
  #  "PathFind::#{sym.to_s.capitalize}::Options".split('::').inject(Object) {|x,y| x.const_get(y) }

  def self.get_options_module(sym)
    case sym
      when :mysql:  PathFinder::Mysql::Options
      when :sql:    PathFinder::Sql::Options
      when :sphinx: PathFinder::Sphinx::Options
    end
  end
  
  def self.get_builder(sym)
    case sym
      when :mysql:  PathFinder::Mysql::Builder
      when :sql:    PathFinder::Sql::Builder
      when :sphinx: PathFinder::Sphinx::Builder
    end
  end

  class Error < RuntimeError
  end

end

require 'path_finder/parsed_path.rb'
require 'path_finder/builder.rb'
require 'path_finder/options.rb'
require 'path_finder/find_by_path.rb'

