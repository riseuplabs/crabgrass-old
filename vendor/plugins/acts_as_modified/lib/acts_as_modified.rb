class Hash
  # Return a hash containing the entries that differ to the passed hash.
  # Blank objects are considered equal.
  # 
  # { 1 => 1, 2 => 3 }.substantial_differences_to({ 1 => 4, 2 => 3 }) => { 1 => 1 }
  # { 1 => 1 }.substantial_differences_to({ 1 => 1 }) => {}
  def substantial_differences_to(hash)
    reject do |key, value|
      hash[key] == value || (hash[key].blank? && value.blank?)
    end
  end
  
  def substantial_difference_to?(hash)
    substantial_differences_to(hash).any?
  end
end

module ActiveRecord
  module Acts
    module Modified
      def self.included(base)
        base.extend(ClassMethods)
        base.class_inheritable_array :excluded_attributes
        base.excluded_attributes = %w(updated_at updated_on)
      end
      
      module ClassMethods
        # == Configuration options
        # 
        # * <tt>clear_after_save</tt> - should the original attributes be cleared after saving, defaults to false. Causes <tt>modified?</tt> to return false after <tt>save</tt> has been called.
        def acts_as_modified(options = {})
          options.assert_valid_keys :clear_after_save, :except
          
          after_save :clear_original_attributes if options[:clear_after_save]
          self.excluded_attributes = [*options[:except]].map!(&:to_s) if options[:except]
          
          unless self.included_modules.include?(ActiveRecord::Acts::Modified::InstanceMethods)
            include InstanceMethods
            
            alias_method_chain :write_attribute, :original_attributes
            alias_method_chain :method_missing, :modified
            alias_method_chain :reload, :clear_original_attributes
            alias_method_chain :read_attribute, :freeze
            alias_method_chain :evaluate_read_method, :freeze
          end
        end
      end
    
      module InstanceMethods
        # Updates the attribute identified by <tt>attr_name</tt> with the specified +value+. Empty strings for fixnum and float columns are turned into nil.
        # The first call causes the original values of all attributes to be stored
        def write_attribute_with_original_attributes(attr_name, value) #:nodoc:
          ensure_original_attribute_stored(attr_name)
          write_attribute_without_original_attributes(attr_name, value)
        end
        
        def read_attribute_with_freeze(attr_name) #:nodoc:
          freeze_attribute(read_attribute_without_freeze(attr_name))
        end
        
        # Like ActiveRecord::Base#attributes_before_type_cast, but returns original attribute values
        def original_attributes_before_type_cast
          clone_attributes :read_original_attribute_before_type_cast
        end
        
        # Like ActiveRecord::Base#attributes, but returns original attribute values
        def original_attributes
          clone_attributes :read_original_attribute
        end
        
        # Like ActiveRecord::Base#read_attribute, but returns original attribute value
        def read_original_attribute(attr_name)
          attr_name = attr_name.to_s
          
          if !original_attribute_stored?(attr_name) or excluded_attributes.include?(attr_name)
            read_attribute(attr_name)
          else
            if !(value = retrieve_original_attribute_value(attr_name)).nil?
              if column = column_for_attribute(attr_name)
                if unserializable_attribute?(attr_name, column)
                  unserialize_attribute(attr_name)
                else
                  column.type_cast(value)
                end
              else
                value
              end
            else
              nil
            end
          end
        end
        
        # Like ActiveRecord::Base#read_attribute_before_type_cast, but returns original attribute value
        def read_original_attribute_before_type_cast(attr_name)
          attr_name = attr_name.to_s
          
          if !original_attribute_stored?(attr_name) or excluded_attributes.include?(attr_name)
            read_attribute_before_type_cast(attr_name)
          else
            retrieve_original_attribute_value(attr_name)
          end
        end
        
        # Replaces the current set of original values with the current attribute values.
        # This makes it as if the attributes were never modified.
        # 
        #  person = Person.find(:first)
        #  person.name = 'New name'
        #  person.modified? # true
        #  
        #  person.clear_original_attributes
        #  
        #  person.modified? # false
        #
        # Pass :only or :except to refine the attributes that this is applied to.
        #
        #  person = Person.find(:first)
        #  person.name = 'New name'
        #  person.age = 49
        #  
        #  person.name_modified? # true
        #  person.age_modified? # true
        #  
        #  person.clear_original_attributes :only => :name
        #  
        #  person.name_modified? # false
        #  person.age_modified? # true
        def clear_original_attributes(options = {})
          attributes_to_clear = case
            when !options[:only] && !options[:except]
              self.class.column_names
            when options[:only]
              Array(options[:only]).map(&:to_s)
            when options[:except]
              except = Array(options[:except]).map(&:to_s)
              self.class.column_names.reject { |c| except.include?(c) }
          end
          
          attributes_to_clear.each do |attribute|
            remove_original_attribute(attribute)
          end
        end
        
        # Returns true if any of the attributes have changed. New records always return false.
        # Pass :reload to compare the current attributes against those in the database.
        # 
        #  person = Person.find(:first)
        #  person.modified? # false
        #  person.name = "New name"
        #  person.modified? # true
        #  person.modified?(:reload) # true
        def modified?(reload = nil)
          return true if new_record?
          return attributes.substantial_difference_to?(self.class.find(id).attributes) if reload
          original_attributes.substantial_difference_to?(attributes)
        end
        
        # Returns a hash containing changed attributes and their original values.
        #
        #  person = Person.find(:first)
        #  person.name # Jonathan
        #  person.name = 'New name'
        #  person.modified_attributes # { "name" => "Jonathan" }
        def modified_attributes
          original_attributes.substantial_differences_to(attributes)
        end
        
        # Restore the attributes to their original values. Use :only or :except to restore specific attributes.
        # 
        #  person = Person.find(:first)
        #  person.name # Jonathan
        #  person.age  # 100
        #  person.name = 'New name'
        #  person.age = 25
        #  
        #  person.restore_attributes # Restores name and age to original values
        #  person.restore_attributes :only => :name # Restores name to its original value
        #  person.restore_attributes :except => [:name, :age] # Restores all attributes except name and age to their original values
        def restore_attributes(options = {})
          original_attributes_before_type_cast = self.original_attributes_before_type_cast.dup
          
          if options[:only]
            only = Array(options[:only]).map(&:to_s)
            original_attributes_before_type_cast.delete_if { |key, value| !only.include?(key) }
          elsif options[:except]
            except = Array(options[:except]).map(&:to_s)
            original_attributes_before_type_cast.delete_if { |key, value| except.include?(key) }
          end
          
          @attributes.update(original_attributes_before_type_cast)
        end
        
        # Use +attribute+_modified? to find out if a specific attribute has been modified.
        # 
        #  person = Person.find(:first)
        #  person.name_modified? # false
        #  person.name = 'New name'
        #  person.name_modified? # true
        #
        # Use original_+attribute+ to get the original value of an attribute.
        # 
        #  person = Person.find(:first)
        #  person.name # 'Jonathan'
        #  person.name = 'Changed'
        #  person.original_name # Jonathan
        #
        # You can also call original_+association+ to get the original object of a belongs_to association.
        # 
        #  <tt>person.original_school</tt> instead of <tt>School.find(person.original_school_id)</tt>
        #
        #  person = Person.find(:first)
        #  person.school_id # 1
        #  person.school_id = 3
        #  person.original_school # will do School.find(1)
        def method_missing_with_modified(method_id, *arguments, &block)
          method_name = method_id.to_s
          if md = /_modified\?$/.match(method_name)
            modified_attributes.has_key? md.pre_match
          elsif md = /^original_/.match(method_name)
            if self.class.column_names.include?(md.post_match)
              read_original_attribute(md.post_match)
            elsif reflection = self.class.reflections[md.post_match.to_sym]
              begin
                reflection.klass.find(read_original_attribute(reflection.primary_key_name))
              rescue ActiveRecord::RecordNotFound
              end
            else
              method_missing_without_modified method_id, *arguments, &block
            end
          else
            method_missing_without_modified method_id, *arguments, &block
          end
        end
        
        # When Base#reload is called, the original attributes should be cleared
        def reload_with_clear_original_attributes #:nodoc:
          clear_original_attributes
          reload_without_clear_original_attributes
        end
        
       private
        def ensure_original_attribute_stored(attr_name)
          attr_name = attr_name.to_s
          if !original_attribute_stored?(attr_name) and !excluded_attributes.include?(attr_name)
            instance_variable_set(original_attribute_variable_name(attr_name), @attributes[attr_name])
          end
        end
        
        def retrieve_original_attribute_value(attr_name)
          instance_variable_get(original_attribute_variable_name(attr_name))
        end
        
        def remove_original_attribute(attr_name)
          remove_instance_variable(original_attribute_variable_name(attr_name)) if original_attribute_stored?(attr_name)
        end
        
        def original_attribute_stored?(attr_name)
          instance_variables.include?(original_attribute_variable_name(attr_name))
        end
        
        def original_attribute_variable_name(attr_name)
          "@__original_#{attr_name}"
        end
        
        def evaluate_read_method_with_freeze(attr_name, method_definition)
          evaluate_read_method_without_freeze(attr_name, method_definition)
          
          # The method name may be different from the attribute name. Extract it from the definition.
          method_name = /def (.+?);/.match(method_definition)[1]
          
          unless method_name.ends_with?('?')
            self.class.class_eval <<-END
              def #{method_name}_with_freeze
                freeze_attribute(#{method_name}_without_freeze)
              end
            END
            
            self.class.alias_method_chain method_name, :freeze
          end
        end
        
        # Running to_s on a frozen Date in Ruby 1.8.6 raises a TypeError (eg: Date.today.freeze.to_s)
        # Work around this by using dup instead.
        def freeze_attribute(value)
          value.is_a?(Date) ? value.dup : value.freeze
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Modified)
