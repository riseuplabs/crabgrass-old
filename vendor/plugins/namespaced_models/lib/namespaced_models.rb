module Inflector
  class << self
    alias_method :original_demodulize, :demodulize
    
    def without_demodulize
      class << self
        define_method(:demodulize) { |s| s }
      end
      yield
    ensure
      class << self
        alias_method :demodulize, :original_demodulize
      end
    end
  end
end

module ActiveRecord
  class Base
    def ensure_proper_type_with_no_demodulize
      Inflector.without_demodulize { ensure_proper_type_without_no_demodulize }
    end
    
    alias_method_chain :ensure_proper_type, :no_demodulize

    class << self
      def type_condition_with_no_demodulize
        Inflector.without_demodulize { type_condition_without_no_demodulize }
      end
      
      alias_method_chain :type_condition, :no_demodulize
      
      # Removes some warnings like "warning: toplevel constant Group referenced by Group::Group"
      def compute_type(type_name)
        begin
          class_eval(type_name, __FILE__, __LINE__)
        rescue
          class_eval(type_name_with_module(type_name), __FILE__, __LINE__)
        end
      end
    end
  end
end

module ActiveRecord
  module Associations
    module ClassMethods
      class JoinDependency
        class JoinAssociation < JoinBase
          def association_join_with_no_demodulize
            Inflector.without_demodulize { association_join_without_no_demodulize }
          end
          
          alias_method_chain :association_join, :no_demodulize
        end
      end
    end
  end
end

module ActiveRecord
  module Associations
    class HasManyThroughAssociation < AssociationProxy
     protected
      def conditions_with_no_demodulize
        Inflector.without_demodulize { conditions_without_no_demodulize }
      end
      
      alias_method_chain :conditions, :no_demodulize
      
      alias_method :sql_conditions, :conditions
    end
  end
end
