=begin

Methods to find pages, for class Page.

Page.find_and_paginate_by_path()
  this is the wiz-bang main function for finding and paginating pages.

Page.find_by_path()
  if you don't need to paginate.

See lib/path_finder/README

We are paginating pages, so the term page is ambiguous. It could mean a Page from the pages table, or it could mean a page of things when paginating. I have tried to use the term 'section' instead of a page for the latter.

=end

module PathFinder
  module FindByPath
  
    def find_by_path(path, options={})
      query_method  = resolve_method(options)
      query_options = resolve_options(query_method, path, options)
      builder = PathFinder.get_builder(options[:method]).new(path, query_options)
      builder.find_pages
    end
    
    def count_by_path(path, options={})
      query_method  = resolve_method(options)
      query_options = resolve_options(query_method, path, options)
      builder = PathFinder.get_builder(options[:method]).new(path, query_options)
      builder.count_pages
    end

    private
    
    def resolve_options(query_method, path, options)
      if options[:callback]
        path = PathFinder::Builder.parse_filter_path(path)
        return PathFinder.get_options_module(query_method).send(options[:callback],path,options)
      else
        return options
      end
    end

    def resolve_method(options)
      options[:method] ||= :sql
      if !ThinkingSphinx.updates_enabled?
        options[:method] = :sql
      end
      options[:method]
    end

  end # FindByPath
end # PathFinder

