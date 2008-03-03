module ThinkingSphinx
  # Represents an index for Sphinx config. Also performs the core part of SQL
  # query generation - although thankfully ActiveRecord does most of the heavy
  # lifting. Syntax examples for indexes can be found at ActiveRecord#define_index.
  class Index
    attr_accessor :model, :fields, :attributes
    
    # Create a new index, passing in the model it is for.
    def initialize(model)
      @model      = model
      @fields     = []
      @attributes = []
      @delta      = false
    end
    
    # Add a new field to the index
    def includes(*args)
      @fields << Field.new(self, args.empty? ? nil : args)
      @fields.last
    end
    
    # Add a new attribute to the index
    def has
      @attributes << Attribute.new(self)
      @attributes.last
    end
        
    # This method grabs all the fields, combines all their associations, and
    # generates usable SQL for the Sphinx configuration file. It makes heavy
    # use of ActiveRecord's Join SQL code - thankfully saving me from going
    # insane.
    def to_sql(d = false)
      associations = {}
      @fields.each { |field| associations[field.unique_name] = field.associations }
      
      level = 0
      next_assocs = associations.collect { |key,value| value[level] }.compact.uniq
      base_dependency = ::ActiveRecord::Associations::ClassMethods::JoinDependency.new(@model, [], nil)
      joins = []
      
      @fields.each do |field|
        parent_join = base_dependency.joins.first
        field.associations.each do |assoc|
          if existing = joins.detect { |join| join.reflection == assoc.reflection }
            parent_join = existing
          else
            joins << ::ActiveRecord::Associations::ClassMethods::JoinDependency::JoinAssociation.new(assoc.reflection, base_dependency, parent_join)
            parent_join = joins.last
          end
        end
        field.prefix = field.associations.empty? ? @model.table_name : joins.last.aliased_table_name
      end
      
      @attributes.each do |attribute|
        attribute.prefix = @model.table_name
      end
      
      join_statement  = joins.collect { |join| join.association_join }.join(" ")
      field_select    = (
        @attributes.collect { |attrib| attrib.select_clause } +
        @fields.collect { |field| field.select_clause }
      ).join(", ")
      group_statement = @fields.collect { |field| field.group_clause }.flatten.compact.uniq.join(", ")
      delta_statement = @delta ? "AND #{@model.table_name}.delta = #{ d ? 1 : 0}" : ""
      
      <<-SQL
SELECT #{@model.table_name}.#{@model.primary_key}, '#{@model}' AS class,
  #{field_select}
FROM #{@model.table_name}
  #{join_statement}
WHERE #{@model.table_name}.#{@model.primary_key} >= $start
  AND #{@model.table_name}.#{@model.primary_key} <= $end
  #{delta_statement}
GROUP BY #{group_statement}
      SQL
    end
    
    # Simple helper method for the query info SQL
    def sql_query_info
      "SELECT * FROM #{@model.table_name} WHERE #{@model.primary_key} = $id"
    end
    
    # Simple helper method for the query range SQL
    def sql_query_range(d = false)
      delta_statement = @delta ? "WHERE #{@model.table_name}.delta = #{ d ? 1 : 0}" : ""
      "SELECT MIN(#{@model.primary_key}), MAX(#{@model.primary_key}) FROM #{@model.table_name} #{delta_statement}"
    end
    
    def sql_query_pre
      delta? ? "UPDATE #{@model.table_name} SET delta = 0" : ""
    end
    
    # Check delta flag
    def delta
      @delta
    end
    
    # Check delta flag
    def delta?
      @delta
    end
    
    # Enable/disable delta
    def delta=(d)
      if d && @model.columns.detect { |col| col.name == "delta" && col.type == :boolean }
        @delta = d
      else
        raise Exception, "Boolean column 'delta' is required for the model"
      end
    end
  end
end