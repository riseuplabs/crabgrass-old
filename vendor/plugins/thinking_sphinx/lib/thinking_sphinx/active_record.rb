module ThinkingSphinx
  # Additions to ActiveRecord models - define_index for creating indexes for
  # models, and search for querying Sphinx. If you want to interrogate the
  # index objects created for the model, you can use the class-level accessor
  # :indexes.
  #
  # Code for after_commit callback is written by Eli Miller:
  # http://elimiller.blogspot.com/2007/06/proper-cache-expiry-with-aftercommit.html
  # with slight modification from Joost Hietbrink.
  #
  module ActiveRecord
    def self.included(base)
      base.class_eval do
        class << self
          attr_accessor :indexes
          
          # Allows creation of indexes for Sphinx. If you don't do this, there
          # isn't much point trying to search (or using this plugin at all,
          # really).
          #
          # An example or two:
          #
          #   define_index do |index|
          #     index.includes(:id).as.model_id
          #     index.includes.name
          #   end
          #
          # You can also grab fields from associations - multiple levels deep
          # if necessary.
          #
          #   define_index do |index|
          #     index.includes.tags.name.as.tag
          #     index.includes.articles.content
          #     index.includes.orders.line_items.product.name.as.product
          #   end
          #
          # And it will automatically concatenate multiple fields:
          #
          #   define_index do |index|
          #     index.includes.author(:first_name, :last_name).as.author
          #   end
          #
          # If you want some (integer, float or timestamp) attributes, the
          # syntax is a little different:
          #
          #   define_index do |index|
          #     index.has.created_at
          #     index.has.updated_at
          #   end
          #
          # Please note that attributes can't be requested from associations.
          #
          # One last feature is the delta index. This requires the model to
          # have a boolean field named 'delta', and is enabled as follows:
          #
          #   define_index do |index|
          #     index.delta = true
          #     # usual attributes and fields go here
          #   end
          #
          # In previous versions of Thinking Sphinx, delta indexes were one
          # step behind the most recent record changes. This has since been
          # fixed.
          #
          def define_index(&block)
            @indexes ||= []
            @indexes << Index.new(self)
            yield @indexes.last
            ThinkingSphinx.indexed_models << self
            
            if @indexes.last.delta?
              before_save   :toggle_delta
              after_commit  :index_delta
            end
            
            @indexes.last
          end

          # Searches for results that match the parameters provided. Will only
          # return the ids for the matching objects. See #search for syntax
          # examples.
          #
          def search_for_ids(*args)
            case args.first
            when String
              str     = args[0]
              options = args[1] || {}
            when Hash
              options = args[0]
              str     = options[:conditions]
            end
            
            str = str.merge(:class => self.name).collect { |key,value|
              value.blank? ? nil : "@#{key} #{value}"
            }.compact.uniq.join(" ") if str.is_a?(Hash)
            page = options[:page].nil? ? 1 : options[:page].to_i
            
            configuration     = ThinkingSphinx::Configuration.new
            sphinx            = Riddle::Client.new
            sphinx.port       = configuration.port
            sphinx.match_mode = options[:match_mode] || :extended
            sphinx.limit      = options[:per_page].nil? ? sphinx.limit : options[:per_page].to_i
            sphinx.offset     = (page - 1) * sphinx.limit
            
            if options[:order]
              sphinx.sort_mode  = :extended
              sphinx.sort_by    = options[:order]
            end
            
            begin
              query = "#{str} @class #{self.name}"
              logger.debug "Sphinx: #{query}"
              results = sphinx.query query
            rescue Errno::ECONNREFUSED => err
              raise Riddle::ConnectionError, "Connection to Sphinx Daemon (searchd) failed."
            end
            
            begin
              pager = WillPaginate::Collection.new(page,
                sphinx.limit, results[:total])
              pager.replace results[:matches].collect { |match| match[:doc] }
            rescue
              results[:matches].collect { |match| match[:doc] }
            end
          end
          
          # Searches for results that match the parameters provided. These
          # parameter keys should match the names of fields in the indexes.
          #
          # This will use WillPaginate for results if the plugin is installed.
          # The same parameters - :page and :per_page - work as expected, and
          # the returned result set can be used by the will_paginate helper.
          #
          # Please use only specified attributes when ordering results -
          # anything else will make the query fall over.
          #
          # Examples:
          #
          #   Invoice.search :conditions => {:customer => "Pat"}
          #   Invoice.search "Pat" # search all fields
          #   Invoice.search "Pat", :page => (params[:page] || 1)
          #   Invoice.search "Pat", :order => "created_at ASC"
          #   Invoice.search "Pat", :include => :line_items
          #
          def search(*args)
            ids = search_for_ids(*args)
            options = args.extract_options!
            ids.replace ids.collect { |id|
              find id, :include => options[:include] rescue nil
            }.compact
          end
          
          def after_commit(*callbacks, &block)
            callbacks << block if block_given?
            write_inheritable_array(:after_commit, callbacks)
          end
        end
        
        def save_with_after_commit_callback(*args)
          value = save_without_after_commit_callback(*args)
          callback(:after_commit) if value
          return value
        end
        
        alias_method_chain :save, :after_commit_callback

        def save_with_after_commit_callback!(*args)
          value = save_without_after_commit_callback!(*args)
          callback(:after_commit) if value
          return value
        end
        
        alias_method_chain :save!, :after_commit_callback

        def destroy_with_after_commit_callback
          value = destroy_without_after_commit_callback
          callback(:after_commit) if value
          return value
        end
        
        alias_method_chain :destroy, :after_commit_callback
        
        private
        
        def toggle_delta
          self.delta = true
        end
        
        def index_delta
          unless RAILS_ENV == "test"
            configuration = ThinkingSphinx::Configuration.new
            system "indexer --config #{configuration.config_file} --rotate #{self.class.name.downcase}_delta"
          end
          true
        end
      end
    end
  end
end