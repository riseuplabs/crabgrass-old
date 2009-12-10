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
  def initialize(path, options, klass)
  end

  # overridden by sub classes
  def build_query_hash()
  end

  # parses path into filters and applies each filter
  def apply_filters_from_path( path )
    if path.is_a?(PathFinder::ParsedPath)
      filters = path
    else
      filters = PathFinder::ParsedPath.new(path)
    end
    filters.each do |filter|
      filter_method = "filter_#{filter[0].gsub('-','_')}"
      args = filter.slice(1..-1) # remove first element.
      #RAILS_DEFAULT_LOGGER.debug [filter, filter_method, args].to_yaml
      self.send(filter_method, *args) if self.respond_to? filter_method
    end
  end

end

