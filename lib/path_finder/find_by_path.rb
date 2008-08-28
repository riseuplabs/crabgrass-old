=begin

Methods to find pages, for class Page.

find_and_paginate_by_path()
this is the wiz-bang main function for finding and paginating pages.
see find_pages() if you don't need to paginate.
we are paginating pages, so the term page is ambiguous.
it could mean a Page from the pages table, or it could mean a page of things
when paginating. i have tried to use the term 'section' instead of a page for the latter.

=end

module PathFinder
  module FindByPath
  
    def find_by_path(path, options={})
      options = apply_possible_lambda(path, options)

      per_page           = options[:per_page] || ::SECTION_SIZE
      page               = options[:page] || 1
      controller         = options[:controller]
      options[:method] ||= :sql
      if !ThinkingSphinx.updates_enabled?
        options[:method] = :sql
      end

      PathFinder::Builder.find_pages(options[:method], path, options)
    end
    
    def count_by_path(path, options={})
      options = apply_possible_lambda(path, options)

      PathFinder::Builder.count_pages(:sql, path, options)
    end
    
    # if the options argument is really a lambda, then call the lambda with
    # the path to get the real options hash    
    def apply_possible_lambda(path, options)
      if options.is_a? Proc
        options.call( PathFinder::Builder.parse_filter_path(path) )
      else
        options
      end
    end

  end # FindByPath
end # PathFinder

