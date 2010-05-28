module ActionView

  module Partials

    @@partioprint_decorators = [LocalsPrinter, PartioPrinter] 
    #@@partioprint_decorators = [PartioPrinter]  Use this for without Local Variable support

    #To store partial and absolute path
    @@filenames = {}

    def render_partial_with_print(options = {})
      result = render_partial_without_print(options)
      options[options[:partial].to_sym] = filenames[options[:partial].to_sym]
      core_printer = CorePrinter.new(result, options)

      printer = core_printer
      for each_decorator in @@partioprint_decorators
        printer = each_decorator.new(printer)
      end

      printer.to_s
    end

    alias_method :render_partial_without_print, :render_partial
    alias_method :render_partial, :render_partial_with_print


    # Allows setting decorators externally
    def self.partioprint_decorators=(decorators)
      @@partioprint_decorators = decorators
    end

    def _pick_partial_template_with_print(partial_path) #:nodoc:
      result = _pick_partial_template_without_print(partial_path)
      @@filenames[partial_path.to_sym] = result.filename
      return result
    end

    alias_method :_pick_partial_template_without_print, :_pick_partial_template
    alias_method :_pick_partial_template, :_pick_partial_template_with_print

    def filenames
      @@filenames
    end

  end

end
