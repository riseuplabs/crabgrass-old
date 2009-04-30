##
## Validate that the password passes cracklib check
##

module CracklibUserExtension

  def self.add_to_class_definition
    lambda do
      validates_each(:password, :if => :password_required?) do |record, attr, value|
        unless record.errors.detect {|err| err.first == "password" }
          # ^^ don't add more errors if there are already some
          result = Cracklib.check(record.login, value)
          unless result == "OK"
            code = Cracklib.translation_key_from_error_message(result)
            record.errors.add attr, result[code]
          end
        end
      end
    end
  end

end

