module ActsAsCrudLimited
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def acts_as_crud_limited()
      before_create :check_create_permission
      before_update :check_update_permission
      before_destroy :check_destroy_permission

      class_eval do

        ##
        ## CALLBACKS
        ##

        ## We default to false. these need to be overridden

        def check_create_permission
          false
        end

        def check_update_permission
          false
        end

        def check_destroy_permission
          false
        end

      end
    end # end acts_as_crud_limited

    def created_by(*args)
      if args.first.is_a? Symbol
        class_eval <<-EOV
          def check_create_permission_with_symbol
            self.name!="bla-#{args.first.to_s}" or check_create_permission_without_symbol
          end
          alias_method_chain :check_create_permission, :symbol
        EOV
      end
    end

  end
end
