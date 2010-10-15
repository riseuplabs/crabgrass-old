module Formy
  module Helper

    def formy(form_type, options={})
      options[:annotate] = RAILS_ENV == 'development'
      class_string = "Formy::" + form_type.to_s.classify
      form = class_string.constantize.new(options)
      form.open
      yield form
      form.close
      form.to_s
    end

  end

end
