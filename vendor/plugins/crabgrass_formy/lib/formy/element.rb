
require 'action_view/helpers/tag_helper'
#require 'active_view/helpers/java_script_helper'

module Formy

  class Element
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::JavaScriptHelper

    def initialize(form,options={})
      @base = form
      @options = options
      if @options[:hide]
        @options[:style] = ['display:none;', @options[:style]].combine
      end
      @elements = []                     # sub elements held by this element
      @buffer = Buffer.new
    end

    # takes "object.attribute" or "attribute" and spits out the
    # correct object and attribute strings.
    def get_object_attr(object_dot_attr)
      object =  object_dot_attr[/^([^\.]*)\./, 1] || @base.options['object']
      attr = object_dot_attr[/([^\.]*)$/]
      return [object,attr]
    end

    def push
      @base.depth += 1
      @base.current_element.push(self)
    end

    def pop
      @base.depth -= 1
      @base.current_element.pop
    end

    def open
      puts "<!-- begin #{self.classname} -->" if @options[:annotate]
      push
    end

    def close
      pop
      puts "<!-- end #{self.classname} -->" if @options[:annotate]
    end

    def classname
      self.class.to_s[/[^:]*$/].downcase
    end

    def to_s
      @buffer.to_s
    end

    def raw_puts(str)
      @buffer << str
    end

    def indent(str)
      ("  " * @base.depth) + str.to_s + "\n"
    end

    def puts(str)
      @buffer << indent(str)
    end

    def parent
      @base.current_element[-2]
    end

    def tag(element_tag, value, options={})
      content_tag(element_tag, value, {:style => @options[:style], :class => @options[:class], :id => @options[:id]})
    end

    def self.sub_element(*class_names)
      for class_name in class_names
        method_name = class_name.to_s.gsub(/^.*::/,'').downcase
        module_eval <<-"end_eval"
        def #{method_name}(options={})
          element = #{class_name}.new(@base,options)
          element.open
          yield element
          element.close
          @elements << element
        end
        end_eval
      end
    end

    def self.element_attr(*attr_names)
      for a in attr_names
        a = a.id2name
        module_eval <<-"end_eval"
        def #{a}(*args)
          if block_given?
            @#{a} = yield
          elsif args.size == 1
            @#{a} = args.first
          else
            @#{a} = args
          end
        end
        end_eval
      end
    end


    # work around rails 2.3.5 to_json circular reference problem
    def to_json
      self.inspect
    end

    def method_missing(method_name, *args, &block)
      word = method_name.id2name
      #e = @current_element.last
      #return unless e
      e = self
      unless e.respond_to? word
        @base.puts "<!-- FORM ERROR: '" + e.classname + "' does not have a '#{word}' -->"
        return
      end
      return e.send(word,args,&block) if block_given?
      return e.send(word,args) if args
      return e.send(word)
    end

  end

end

