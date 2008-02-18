module ThinkingSphinx
  # Represents a field within an index. Handles some of the magic around the
  # associations chaining.
  class Attribute
    attr_accessor :index, :column, :prefix
    
    # Pass in the index this field is tied to, as well as the column name (if
    # there is one at this point).
    def initialize(index)
      @index = index
      @expecting_as   = false
    end
    
    # Mark this field as expecting an alias
    def as(as=nil)
      as.nil? ? @expecting_as = true : @as = as
      self
    end
    
    # The alias, if there is one, otherwise the column name
    def unique_name
      @as || @column
    end
    
    # Returns this field's part of the SQL SELECT clause - adds concats and
    # group concats when necessary. 
    def select_clause
      if timestamp?
        "UNIX_TIMESTAMP(`#{@prefix}`.`#{@column}`) AS `#{self.unique_name}`"
      else
        "`#{@prefix}`.`#{@column}` AS `#{self.unique_name}`"
      end
    end
    
    # Returns this field's part of the SQL GROUP clause - if appropriate.
    def group_clause
      nil
    end
    
    def timestamp?
      index.model.columns.any? { |col|
        col.name == @column.to_s && col.type == :datetime
      }
    end
    
    # Here lies a lot of the magic related to finding attributes and
    # associations from index definitions. Will error if the association or
    # attribute does not exist.
    def method_missing(method, *args)
      if args.empty? and @expecting_as
        @as = method
        @expecting_as = false
        return self
      end
      
      if index.model.columns_hash[method.to_s].nil?
        raise ArgumentError, "Model #{model.name} does not have the following attribute: #{method}"
      end
      
      @column = method
      self
    end
  end
end
