module Undress
  # Grammars give you a DSL to declare how to convert an HTML document into a
  # different markup language.
  class Grammar
    def self.inherited(base) # :nodoc:
      base.instance_variable_set(:@post_processing_rules, post_processing_rules)
      base.instance_variable_set(:@pre_processing_rules, pre_processing_rules)
    end

    # Add a parsing rule for a group of html tags.
    #
    #     rule_for :p do |element|
    #       "<this was a paragraph>#{content_of(element)}</this was a paragraph>"
    #     end
    #
    # will replace your <tt><p></tt> tags for <tt><this was a paragraph></tt> 
    # tags, without altering the contents.
    #
    # The element yielded to the block is an Hpricot element for the given tag.
    def self.rule_for(*tags, &handler) # :yields: element
      tags.each do |tag|
        define_method tag.to_sym, &handler
      end
    end

    # Set a default rule for unrecognized tags.
    #
    # Unless you define a special case, it will ignore the tags and just output
    # the contents of unrecognized tags.
    def self.default(&handler) # :yields: element
      define_method :method_missing do |tag, node, *args|
        handler.call(node)
      end
    end

    # Add a post-processing rule to your parser.
    #
    # This takes a regular expression that will be applied to the output after
    # processing any nodes. It can take a string as a replacement, or a block
    # that will be passed to String#gsub.
    #
    #     post_processing(/\n\n+/, "\n\n") # compress more than two newlines
    #     post_processing(/whatever/) { ... }
    def self.post_processing(regexp, replacement = nil, &handler) #:yields: matched_string
      post_processing_rules[regexp] = replacement || handler
    end

    # Add a pre-processing rule to your parser.
    #
    # This lets you mutate the DOM before applying any rule defined with
    # +rule_for+. You need to pass a CSS/XPath selector, and a block that
    # takes an Hpricot element to parse it.
    #
    #     pre_processing "ul.toc" do |element|
    #       element.swap("<p>[[toc]]</p>")
    #     end
    #
    # Would replace any unordered lists with the class +toc+ for a
    # paragraph containing the code <tt>[[toc]]</tt>.
    def self.pre_processing(selector, &handler) # :yields: element
      pre_processing_rules[selector] = handler
    end

    def self.post_processing_rules #:nodoc:
      @post_processing_rules ||= {}
    end

    def self.pre_processing_rules #:nodoc:
      @pre_processing_rules ||= {}
    end

    def self.process!(node) #:nodoc:
      new.process!(node)
    end

    attr_reader :pre_processing_rules #:nodoc:
    attr_reader :post_processing_rules #:nodoc:

    def initialize #:nodoc:
      @pre_processing_rules = self.class.pre_processing_rules.dup
      @post_processing_rules = self.class.post_processing_rules.dup
    end

    # Process a DOM node, converting it to your markup language according to
    # your defined rules. If the node is a Text node, it will return it's
    # string representation. Otherwise it will call the rule defined for it.
    def process(nodes)
      Array(nodes).map do |node|
        if node.text?
          node.to_html
        elsif node.elem? 
          send node.name.to_sym, node if ALLOWED_TAGS.empty? || ALLOWED_TAGS.include?(node.name)
        else
          ""
        end
      end.join("")
    end

    def process!(node) #:nodoc:
      pre_processing_rules.each do |selector, handler|
        node.search(selector).each(&handler)
      end

      process(node.children).tap do |text|
        post_processing_rules.each do |rule, handler|
          handler.is_a?(String) ?  text.gsub!(rule, handler) : text.gsub!(rule, &handler)
        end
      end
    end

    # Get the result of parsing the contents of a node.
    def content_of(node)
      process(node.respond_to?(:children) ? node.children : node)
    end

    # Helper method that tells you if the given DOM node is immediately
    # surrounded by whitespace.
    def surrounded_by_whitespace?(node)
      (node.previous.text? && node.previous.to_s =~ /\s+$/) ||
        (node.next.text? && node.next.to_s =~ /^\s+/)
    end

    def method_missing(tag, node, *args) #:nodoc:
      process(node.children)
    end
  end
end
