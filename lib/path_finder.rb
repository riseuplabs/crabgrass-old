
module PathFinder

  def self.get_options_module(sym)
    PathFinder.const_get('%sOptions'%sym.to_s.capitalize)
  end
  
  def self.get_builder(sym)
    PathFinder.const_get('%sBuilder'%sym.to_s.capitalize)
  end

  class Error < RuntimeError
  end

end

require 'path_finder/parsed_path.rb'
require 'path_finder/builder.rb'
require 'path_finder/sql_builder.rb'
require 'path_finder/sql_builder_filters.rb'
require 'path_finder/sphinx_builder.rb'
require 'path_finder/sphinx_builder_filters.rb'
require 'path_finder/options.rb'
require 'path_finder/find_by_path.rb'

