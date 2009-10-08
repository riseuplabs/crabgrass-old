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

        ## Only if we are using the Console User.current is nil.
        ## Otherwise this is false so these need to be overridden / or'ed

        def check_create_permission
          User.current.nil?
        end

        def check_update_permission
          User.current.nil?
        end

        def check_destroy_permission
          User.current.nil?
        end

      end
    end # end acts_as_crud_limited

    def permit(*args)
      wrap_with_new_permission(*args)
    end

    def restrict(*args)
      args << args.extract_options!.merge!(:restrict=>true)
      wrap_with_new_permission(*args)
    end

    private
    def wrap_with_new_permission(*args)
      action = args.first
      options = args.extract_options!
      class_eval method_template(action, options)
    end

    def method_template(action, options)
      role = options[:to]
      target = options[:of] || "self"
      restrict = options[:restrict] || false
      condition = options[:if].nil? ? nil : " && self.send(:#{options[:if]})"
      modifier = target == "self" ? role : "#{role}_of_#{target}"
      return <<-EOV
          def check_#{action}_permission_with_#{modifier}
            check_#{action}_permission_without_#{modifier} #{restrict ? "or" : "and"}
              current_user.may?(:#{role}, #{target}) #{condition}
          end
          alias_method_chain :check_#{action}_permission, :#{modifier}
          EOV
    end

  end
end
