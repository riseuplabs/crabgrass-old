module ActiveRecord::Validations
  module ClassMethods

    # acts the same as 'validates_presence_of :attr_name
    # except a list of attr names must be set for each object
    # like this: page.optional_validation_attributes = [:summary, :body]
    def validates_presence_of_optional_attributes
      class_eval do
        attr_accessor :optional_validation_attributes
        validate :has_optional_validation_attributes?

        def has_optional_validation_attributes?
          return false unless optional_validation_attributes.respond_to?(:each)

          has_all_attributes = true
          optional_validation_attributes.each do |attr_name|
            value = self.respond_to?(attr_name.to_s) ? self.send(attr_name.to_s) : self[attr_name.to_s]
            if value.blank?
              self.errors.add_on_blank(attr_name, I18n.t(:is_required))
              has_all_attributes = false
            end
          end
          # return nil if errors don't contain validation attributes
          return has_all_attributes
        end
      end

    end

  end
end
