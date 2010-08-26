if defined? ActiveSupport::Callbacks
  
  module AfterCommit
    module ActiveSupportCallbacks
      def self.included(base)
        
        base::Callback.class_eval do
          def have_callback?
            true
          end
        end
        
        base::CallbackChain.class_eval do
          def have_callback?
            any? &:have_callback?
          end
        end
        
        base.class_eval do
          def have_callback?(*callbacks)
            self.class.observers.size > 0 or
            self.class.count_observers > 0 or
            callbacks.any? do |callback|
              self.class.send("#{callback}_callback_chain").have_callback?
            end
          end
        end
        
      end
    end
  end
  ActiveSupport::Callbacks.send(:include, AfterCommit::ActiveSupportCallbacks)
  
else
  
  class ActiveRecord::Base
    
    def self.define_callbacks(*names)
      names.each do |name|
        instance_eval <<-RUBY
          def #{name}(*callbacks, &block)
            callbacks << block if block_given?
            write_inheritable_array(:#{name}, callbacks)
          end
        RUBY
      end
    end
    
    def have_callback?(*names)
      self.class.observers.size > 0 or
      self.class.count_observers > 0 or
      names.any? do |name|
        !self.class.read_inheritable_attribute(name).blank?
      end
    end
    
  end
  
end
