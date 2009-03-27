# = PathFinder::Builder
# 
# An abstract super class of 
# PathFinder::Sql::Builder,
# PathFinder::Mysql::Builder and
# PathFinder::Sphinx::Builder
#
# This is called from FindByPath.

class PathFinder::Builder

  # overridden by sub classes
  def initialize(path, options)
  end
  
  # overridden by sub classes
  def build_query_hash()
  end
  
  # parses path into filters and applies each filter
  def apply_filters_from_path( path )
    filters = PathFinder::ParsedPath.new( path )
    filters.each do |filter|
      filter_method = "filter_#{filter[0].gsub('-','_')}"
      args = filter.slice(1..-1) # remove first element.
      #RAILS_DEFAULT_LOGGER.debug [filter, filter_method, args].to_yaml
      self.send(filter_method, *args) if self.respond_to? filter_method
    end
  end
 
  # i think this is not used
  #def self.parse_filter_path(path)
  #  PathFinder::ParsedPath.new( path )
  #end
  #
  #def parse_filter_path(path)
  #  PathFinder::ParsedPath.new( path )
  #end
  
  #
  # given a hash search options (like might be returned
  # in params[:search], build a filter path. For example:
  # in:
  #   {"month"=>"6", "pending"=>"true"}
  # out:
  #   /month/6/pending
  #
  #def self.build_filter_path(search)
  #  PathFinder::ParsedPath.new(search).to_s
  #end

  # make sure that path is an array, not a '/' delimited string
  def cleanup_path(path)
    if path.is_a? String
      path.split('/') 
    elsif path.is_a? Array
      path
    end
  end
  
  
end

