module Globalize # :nodoc:

  class WrongLanguageError < ActiveRecord::ActiveRecordError
    attr_reader :original_language, :active_language
    def initialize(orig_lang, active_lang)
      @original_language = orig_lang
      @active_language   = active_lang
    end
  end
  
  class TranslationTrampleError < ActiveRecord::ActiveRecordError; end

  module DbTranslate  # :nodoc:

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
=begin rdoc
          Specifies fields that can be translated. These are normal ActiveRecord
          fields, with corresponding database columns, but they are shadowed
          by translations in a special translation table. All the translation
          stuff is done behind the scenes.
          
          === Example:
          
          ==== In your model:
            class Product < ActiveRecord::Base
              translates :name, :description
            end
          
          ==== In your controller:
            Locale.set("en_US")
            product.name -> guitar
            
            Locale.set("es_ES")
            product.name -> guitarra
            
        The standard ActiveRecord +find+ method has been tweaked to work with Globalize.
        Use it in the exact same way you would the regular find, except for the 
        following provisos:

        1. At this point, it will not work with the <tt>:include</tt> option...
        1. However, there is a replacement: <tt>:include_translated</tt>, which will 
         be described below.
        1. The <tt>:select</tt> option is prohibited.

        +find+ returns the retreived models, with all translated fields correctly
        loaded, depending on the active language.
            
        <tt>:include_translated</tt> works as follows: 
        any model specified in the <tt>:include_translated</tt> option
        will be eagerly loaded and added to the current model as attributes,
        prefixed with the name of the associated model. This is often referred
        to as _piggybacking_.

        Example:
          class Product < ActiveRecord::Base
            belongs_to :manufacturer
            belongs_to :category
          end

          class Category < ActiveRecord::Base
            has_many :products
            translates :name
          end

          prods = Product.find(:all, :include_translated => [ :manufacturer, :category ])
          prods.first.category_name -> "batedeira"            
=end
      def translates(*facets)
        # parse out options hash
        options = facets.pop if facets.last.kind_of? Hash
        options ||= {}

        facets_string = "[" + facets.map {|facet| ":#{facet}"}.join(", ") + "]"
        class_eval <<-HERE   
          @@facet_options = {}
          attr_writer :fully_loaded
          def fully_loaded?; @fully_loaded; end
          @@globalize_facets = #{facets_string}
          @@preload_facets ||= @@globalize_facets
          class << self

            def sqlite?; connection.kind_of? ActiveRecord::ConnectionAdapters::SQLiteAdapter end

            def globalize_facets
              @@globalize_facets
            end

            def globalize_facets_hash
              @@globalize_facets_hash ||= globalize_facets.inject({}) {|hash, facet|
                hash[facet.to_s] = true; hash
              }
            end            

            def untranslated_fields
              @@untranslated_fields ||= 
                column_names.map {|cn| cn.intern } - globalize_facets
            end

            def preload_facets; @@preload_facets; end
            def postload_facets
              @@postload_facets ||= @@globalize_facets - @@preload_facets
            end
            alias_method :globalize_old_find_every, :find_every unless
              respond_to? :globalize_old_find_every
          end
          alias_method :globalize_old_reload,   :reload
          alias_method :globalize_old_destroy,  :destroy
          alias_method :globalize_old_create_or_update, :create_or_update
          alias_method :globalize_old_update, :update        
          
          include Globalize::DbTranslate::TranslateObjectMethods
          extend  Globalize::DbTranslate::TranslateClassMethods        

        HERE

        facets.each do |facet|
          bidi = (!(options[facet] && !options[facet][:bidi_embed])).to_s
          class_eval <<-HERE
            @@facet_options[:#{facet}] ||= {}
            @@facet_options[:#{facet}][:bidi] = #{bidi}

            def #{facet}
              if not_original_language
                raise WrongLanguageError.new(@original_language, Locale.language)
              end
              load_other_translations if 
                !fully_loaded? && !self.class.preload_facets.include?(:#{facet})
              result = read_attribute(:#{facet})
              return nil if result.nil?
              result.direction = #{facet}_is_base? ? 
                (Locale.base_language ? Locale.base_language.direction : nil) : 
                (@original_language ? @original_language.direction : nil)

              # insert bidi embedding characters, if necessary
              if @@facet_options[:#{facet}][:bidi] && 
                  Locale.language && Locale.language.direction && result.direction
                if Locale.language.direction == 'ltr' && result.direction == 'rtl'
                  bidi_str = "\xe2\x80\xab" + result + "\xe2\x80\xac"
                  bidi_str.direction = result.direction
                  return bidi_str
                elsif Locale.language.direction == 'rtl' && result.direction == 'ltr'
                  bidi_str = "\xe2\x80\xaa" + result + "\xe2\x80\xac"
                  bidi_str.direction = result.direction
                  return bidi_str
                end
              end
              
              return result
            end

            def #{facet}=(arg)
              raise WrongLanguageError.new(@original_language, Locale.language) if
                not_original_language
              write_attribute(:#{facet}, arg)
            end

            def #{facet}_is_base?
              self['#{facet}_not_base'].nil?
            end          
          HERE
        end

      end

=begin rdoc
      Optionally specifies translated fields to be preloaded on <tt>find</tt>. For instance,
      in a product catalog, you may want to do a <tt>find</tt> of the first 10 products:

        Product.find(:all, :limit => 10, :order => "name")

      But you wouldn't want to load the complete descriptions and specs of all the
      products, just the names and summaries. So you'd specify:

        class Product < ActiveRecord::Base
          translates :name, :summary, :description, :specs
          translates_preload :name, :summary
          ...
        end

      By default (if no translates_preload is specified), Globalize will preload
      the first field given to <tt>translates</tt>. It will also fully load on
      a <tt>find(:first)</tt> or when <tt>:translate_all => true</tt> is given as a find option.
=end
      def translates_preload(*facets)
      module_eval <<-HERE
        @@preload_facets = facets
      HERE
      end

    end

    module TranslateObjectMethods # :nodoc: all

      module_eval <<-HERE
      def not_original_language
        return false if @original_language.nil?
        return @original_language != Locale.language
      end

      def set_original_language
        @original_language = Locale.language      
      end
      HERE

      def load_other_translations
        postload_facets = self.class.postload_facets
        return if postload_facets.empty? || new_record?

        table_name = self.class.table_name
        facet_selection = postload_facets.join(", ")
        base = connection.select_one("SELECT #{facet_selection} " +
          " FROM #{table_name} WHERE #{self.class.primary_key} = #{id}", 
          "loading base for load_other_translations")
        base.each {|key, val| write_attribute( key, val ) }

        unless Locale.base?
          trs = ModelTranslation.find(:all, 
            :conditions => [ "table_name = ? AND item_id = ? AND language_id = ? AND " +
            "facet IN (#{[ '?' ] * postload_facets.size * ', '})", table_name,
            self.id, Locale.active.language.id ] + postload_facets.map {|facet| facet.to_s} )
          trs ||= []
          trs.each do |tr|
            attr = tr.text || base[tr.facet.to_s]
            write_attribute( tr.facet, attr )
          end
        end
        self.fully_loaded = true
      end

      def destroy
        globalize_old_destroy
        ModelTranslation.delete_all( [ "table_name = ? AND item_id = ?", 
          self.class.table_name, id ])        
      end

      def reload
        globalize_old_reload
        set_original_language
      end

      private  
      
        # Returns copy of the attributes hash where all the values have been safely quoted for use in
        # an SQL statement.
        # REDEFINED to include only untranslated fields. We don't want to overwrite the 
        # base translation with other translations.
        def attributes_with_quotes(include_primary_key = true)
          if Locale.base?
            attributes.inject({}) do |quoted, (name, value)|
              if column = column_for_attribute(name)
                quoted[name] = quote(value, column) unless !include_primary_key && column.primary
              end
              quoted
            end
          else
            attributes.inject({}) do |quoted, (name, value)|
              if !self.class.globalize_facets_hash.has_key?(name) && 
                  column = column_for_attribute(name)
                quoted[name] = quote(value, column) unless !include_primary_key && column.primary
              end
              quoted
            end
          end          
        end

        def create_or_update
          result = globalize_old_create_or_update
          update_translation if Locale.active && result
          result
        end
        
        def update
          status = true
          status = globalize_old_update unless attributes_with_quotes(false).empty?
          status
        end
        
        def update_translation
          raise WrongLanguageError.new(@original_language, Locale.language) if
            not_original_language

          set_original_language

          # nothing to do, facets updated in main model
          return if Locale.base?

          table_name = self.class.table_name
          self.class.globalize_facets.each do |facet|
            next unless has_attribute?(facet)
            text = read_attribute(facet)
            language_id = Locale.active.language.id
            tr = ModelTranslation.find(:first, :conditions =>
              [ "table_name = ? AND item_id = ? AND facet = ? AND language_id = ?",
              table_name, id, facet.to_s, language_id ])
            if tr.nil?
              # create new record
              ModelTranslation.create(:table_name => table_name, 
                :item_id => id, :facet => facet.to_s, 
                :language_id => language_id,
                :text => text) unless text.nil?
            elsif text.blank?
              # delete record
              tr.destroy
            else
              # update record
              tr.update_attribute(:text, text) if tr.text != text
            end
          end # end facets loop
        end

    end

    module TranslateClassMethods

      # Use this instead of +find+ if you want to bypass the translation
      # code for any reason. 
      def untranslated_find(*args)
        has_options = args.last.is_a?(Hash)
        options = has_options ? args.last : {}
        options[:untranslated] = true
        args << options if !has_options
        find(*args)
      end
      
      protected
        # FIX: figure out how to use default rails VALID_FIND_OPTIONS constant
        VALID_FIND_OPTIONS = [ :conditions, :include, :joins, :limit, :offset,
                               :order, :select, :readonly, :group, :from, 
                               :untranslated, :include_translated ]

        def validate_find_options(options) #:nodoc:
          options.assert_valid_keys(VALID_FIND_OPTIONS)
        end
      
      private
        def find_every(options)
          return globalize_old_find_every(options) if options[:untranslated]
          raise StandardError, 
            ":select option not allowed on translatable models " +
            "(#{options[:select]})" if options[:select] && !options[:select].empty?

          # do quick version if base language is active
          if Locale.base? && !options.has_key?(:include_translated) 
            results = globalize_old_find_every(options) 
            results.each {|result|
              result.set_original_language
            }
            return results
          end

          options[:conditions] = fix_conditions(options[:conditions]) if options[:conditions]

          # there will at least be an +id+ field here
          select_clause = untranslated_fields.map {|f| "#{table_name}.#{f}" }.join(", ")

          joins_clause = options[:joins].nil? ? "" : options[:joins].dup
          joins_args = []
          load_full = options[:translate_all]
          facets = load_full ? globalize_facets : preload_facets

          if Locale.base?
            select_clause <<  ', ' << facets.map {|f| "#{table_name}.#{f}" }.join(", ")
          else
            language_id = Locale.active.language.id
            load_full = options[:translate_all]
            facets = load_full ? globalize_facets : preload_facets
            
=begin
          There's a bug in sqlite that messes up sorting when aliasing fields, 
          see: <http://www.sqlite.org/cvstrac/tktview?tn=1521,33>.

          Since I want to use sqlite, and sorting, I'm hacking this to make it work.
          This involves renaming order by fields and adding them to the SELECT part. 
          It's a sucky hack, but hopefully sqlite will fix the bug soon.
=end

            # sqlite bug hack          
            select_position = untranslated_fields.size

            # initialize where tweaking
            if options[:conditions].nil?
              where_clause = ""
            else
              if options[:conditions].kind_of? Array          
                conditions_is_array = true
                where_clause = options[:conditions].shift
              else
                where_clause = options[:conditions]
              end
            end

            facets.each do |facet| 
              facet = facet.to_s
              facet_table_alias = "t_#{facet}"

              # sqlite bug hack          
              select_position += 1
              options[:order].sub!(/\b#{facet}\b/, select_position.to_s) if options[:order] && sqlite?

              select_clause << ", COALESCE(#{facet_table_alias}.text, #{table_name}.#{facet}) AS #{facet}, " 
              select_clause << " #{facet_table_alias}.text AS #{facet}_not_base " 
              joins_clause  << " LEFT OUTER JOIN globalize_translations AS #{facet_table_alias} " +
                "ON #{facet_table_alias}.table_name = ? " +
                "AND #{table_name}.#{primary_key} = #{facet_table_alias}.item_id " +
                "AND #{facet_table_alias}.facet = ? AND #{facet_table_alias}.language_id = ? "
              joins_args << table_name << facet << language_id            
              
              #for translated fields inside WHERE clause substitute corresponding COALESCE string
              where_clause.gsub!(/((((#{table_name}\.)|\W)#{facet})|^#{facet})\W/, " COALESCE(#{facet_table_alias}.text, #{table_name}.#{facet}) ")          
            end
            
            options[:conditions] = sanitize_sql( 
              conditions_is_array ? [ where_clause ] + options[:conditions] : where_clause 
            ) unless options[:conditions].nil?          
          end

          # add in associations (of :belongs_to nature) if applicable
          associations = options[:include_translated] || []
          associations = [ associations ].flatten
          associations.each do |assoc|
            rfxn = reflect_on_association(assoc)
            assoc_type = rfxn.macro
            raise StandardError, 
              ":include_translated associations must be of type :belongs_to;" +
              "#{assoc} is #{assoc_type}" if assoc_type != :belongs_to
            klass = rfxn.klass
            assoc_facets = klass.preload_facets
            included_table = klass.table_name
            included_fk = klass.primary_key
            fk = rfxn.options[:foreign_key] || "#{assoc}_id"
            assoc_facets.each do |facet|
              facet_table_alias = "t_#{assoc}_#{facet}"

             if Locale.base?
                select_clause << ", #{included_table}.#{facet} AS #{assoc}_#{facet} "
              else            
                select_clause << ", COALESCE(#{facet_table_alias}.text, #{included_table}.#{facet}) " +
                  "AS #{assoc}_#{facet} "
                joins_clause << " LEFT OUTER JOIN globalize_translations AS #{facet_table_alias} " +
                  "ON #{facet_table_alias}.table_name = ? " +
                  "AND #{table_name}.#{fk} = #{facet_table_alias}.item_id " +
                  "AND #{facet_table_alias}.facet = ? AND #{facet_table_alias}.language_id = ? "
                joins_args << klass.table_name << facet.to_s << language_id                        
              end                        
            end
            joins_clause << "LEFT OUTER JOIN #{included_table} " + 
                "ON #{table_name}.#{fk} = #{included_table}.#{included_fk} "
          end

          options[:select] = select_clause
          options[:readonly] = false

          sanitized_joins_clause = sanitize_sql( [ joins_clause, *joins_args ] )        
          options[:joins] = sanitized_joins_clause
          results = globalize_old_find_every(options)

          results.each {|result|
            result.set_original_language
            result.fully_loaded = true if load_full
          }
          
          return results
        end

        # properly scope conditions to table
        def fix_conditions(conditions)
          if conditions.kind_of? Array          
            is_array = true
            sql = conditions.shift
          else
            is_array = false
            sql = conditions
          end

          column_names.each do |column_name|
            sql.gsub!( /(^|([^\.\w"'`]+))(["'`]?)#{column_name}(?!\w)/,
              '\1' + "#{table_name}." + '\3' + "#{column_name}" )           
          end

          if is_array
            [ sql ] + conditions
          else
            sql
          end
        end

    end
  end

end
