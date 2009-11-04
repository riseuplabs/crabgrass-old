##
## enforces a not-aweful password
##

module PasswordStrengthUserExtension

  def self.add_to_class_definition
    lambda do
      validates_each(:password, :if => :password_required?) do |record, attr, value|
        unless record.errors.detect {|err| err.first == "password" }
          # ^^ don't add more errors if there are already some
          unless PasswordStrength.check_strength(value)
            record.errors.add(attr, I18n.t(:password_error_default))
          end
          if value == record.login
            record.errors.add(attr, I18n.t(:password_error_username))
          end
        end
      end
    end
  end

end


