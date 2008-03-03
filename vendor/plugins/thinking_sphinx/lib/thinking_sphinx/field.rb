module ThinkingSphinx
  # Represents a field within an index. Handles some of the magic around the
  # associations chaining.
  class Field
    attr_accessor :index, :column, :associations, :prefix
    
    # Pass in the index this field is tied to, as well as the column name (if
    # there is one at this point).
    def initialize(index, column=nil)
      column = column.first if column.is_a?(Array) && column.length == 1
      
      @index, @column = index, column
      @associations   = []
      @expecting_as   = false
      @with_prefixes  = false
      @with_infixes   = false
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
    
    # Indication of whether there are multiple records of this field in
    # relation to the base model.
    def many?
      associations.any? { |assoc| [:has_many, :has_and_belongs_to_many].include?(assoc.reflection.macro) }
    end
    
    # Returns this field's part of the SQL SELECT clause - adds concats and
    # group concats when necessary. 
    def select_clause
      return @column if @column.is_a?(String)
      
      clause = Array(@column).collect { |col| "#{self.prefix}.#{col}" }.join(", ")
      clause = "CONCAT_WS(' ', #{clause})" if @column.is_a?(Array)
      
      if self.many?
        "CAST(GROUP_CONCAT(#{clause} SEPARATOR ' ') AS CHAR) AS #{self.unique_name}"
      else
        "CAST(#{clause} AS CHAR) AS #{self.unique_name}"
      end
    end
    
    # Returns this field's part of the SQL GROUP clause - if appropriate.
    def group_clause
      return nil if self.many?
      Array(@column).collect { |col| "#{self.prefix}.#{col}" }.join(", ")
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
      
      model = (associations.last || index).model
      raise ArgumentError.new if model.nil?
      
      if model.columns_hash[method.to_s].nil?
        reflection = model.reflect_on_association(method)
        raise ArgumentError.new("Model #{model.name} does not have an attribute or association called #{method}") if reflection.nil?
        
        @associations << Association.new(self, method, reflection)
        model = associations.last.model
      else
        @column = method
      end
      
      return self if args.empty?
      
      if args.any? { |arg| model.columns_hash[arg.to_s].nil? }
        raise ArgumentError, "Model #{model.name} does not have all of the following attributes: #{args.join(', ')}"
      else
        @column = args.length == 1 ? args.first : args
        return self
      end
    end
  end
end