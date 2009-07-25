=begin

FORMY -- a form creator for rails

<%= Formy.form :option => value do |f|
  f.title "My Form"
  f.label "Mail Client"
  f.row do |r|
    r.info "info about this row"
    r.label "row label"
    r.input text_field('object','method')
  end
end %>

A form consistants of a tree of elements.
Each element may contain other elements.
In the close method of each element, the element
must render its contents to its local string buffer.
the parent element then uses that buffer when doing
its own rendering.

Examples
===================================================

Javascript Tabs
---------------

the rules for javascript tabs:
(1) the dom id passed to t.show_tab() must match the dom id
    of the div to be shown.
(2) the div must have the class tab-content
    in order for it to be hidden. (the class tap-area is
    optional, it does the styling).
(3) whichever tab you make selected by default should
    also have its area visible by default, and the others hidden.

<%= Formy.tabs do |f|
  f.tab do |t|
    t.label 'Tab One'
    t.show_tab 'tab-one-div'
    t.selected true
  end
  f.tab do |t|
    t.label 'Tab Two'
    t.show_tab 'tab-two-div'
    t.selected false
  end
  f.tab do |t|
    t.label 'Ajax Link'
    t.click remote_function(:url=>{:action => 'ajaxy_thing'})
    t.selected false
  end
end
%>

<div class='tab_content' id='tab-one-div'>
  <%= render :partial => 'something/good' %>
</div>

<div class='tab_content' id='tab-two-div' style='display:none'>
  <%= render :partial => 'something/better' %>
</div>

=end

module Formy
  # <% _erbout << "foo" %>
  # <% concat("foo", binding) %>

#  def self.define_formy_keywords
#    # could be replaced with method missing?
#    form_word :title, :row, :label, :info, :heading, :input, :section, :spacer,
#       :checkbox, :tab, :link, :selectedx
#  end

  ##
  ## FORM CREATION
  ##

  def self.create(options={})
    @@base = f = Form.new(options)
    f.open
    yield f
    f.close
    f.to_s
  end
  def self.form(options={},&block); self.create(options,&block); end

  def self.tabs(options={})
    @@base = f = Tabset.new(options)
    f.open
    yield f
    f.close
    f.to_s
  end

  def self.sidebar(options={})
    @@base = f = Sidebar.new(options)
    f.open
    yield f
    f.close
    f.to_s
  end

  ##
  ## HELPER METHODS
  ##

  # sets up form keywords. when a keyword is called,
  # it tries to call this method on the current form element.
  def self.form_word(*keywords)
    for word in keywords
      word = word.id2name
      module_eval <<-"end_eval"
      def #{word}(options=nil,&block)
        e = @@base.current_element.last
        return unless e
        unless e.respond_to? "#{word}"
          @@base.puts "<!-- FORM ERROR: '" + e.classname + "' does not have a '#{word}' -->"
          return
        end
        return e.#{word}(options,&block) if block_given?
        return e.#{word}(options) if options
        return e.#{word}()
      end
      end_eval
    end
  end

  def url_to_hash(url)
    path = url.to_s.split('/')[(3..-1)]
    ActionController::Routing::Routes.recognize_path(path)
  end

  ##
  ## BASE CLASSES
  ##

  class Buffer
    def initialize
      @data = ""
    end
    def <<(str)
      @data << str.to_s
    end
    def to_s
      @data
    end
  end

  class Element
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::JavascriptHelper

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
      puts "<!-- begin #{self.classname} -->"
      push
    end

    def close
      pop
      puts "<!-- end #{self.classname} -->"
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
        def #{a}(value=nil)
          if block_given?
            @#{a} = yield
          else
            @#{a} = value
          end
        end
        end_eval
      end
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

  class Root < Element
    attr_accessor :depth, :current_element
    attr_reader :options

    def initialize(options={})
      super(self,options)
      @depth = 0
      @base = self
      @current_element = [self]
    end
  end

  #### TAB CLASSES ##################################################

  class Tabset < Root
    class Tab < Element
      # required: label & ( link | url | show_tab )
      #
      # if show_tab is set to an dom id that ends in '_panel', then special things happen:
      #
      #  (1) the link is given an id with _panel replaced by _link
      #  (2) the window.location.hash is set by removing '_panel'
      #
      # optional attributes:
      #   selected -- tab is active if true
      #   icon -- name of an icon to give the tab
      #   id -- dom id for the tab link
      #   style -- custom css
      #   class -- custom css class
      #
      # show_tab modifiers:
      #   hash -- overide default location.hash that is activated when this tab is activated
      #   default -- if true, this is the default tab that gets loaded.
      #
      element_attr :label, :link, :show_tab, :url, :selected, :icon, :id, :style, :class, :hash, :default

      def close
        selected = 'active' if "#{@selected}" == "true"
        @class = [@class, selected, ("small_icon #{@icon}_16" if @icon)].compact.join(' ')
        if @link
          a_tag = @link
        elsif @url
          a_tag = content_tag :a, @label, :href => @url, :class => @class, :style => @style, :id => @id
        elsif @show_tab
          if @show_tab =~ /_panel$/
            @hash ||= @show_tab.sub(/_panel$/, '').gsub('_','-')
            onclick = "showTab(this, $('%s'), '%s')" % [@show_tab, @hash]
            @id = @show_tab.sub(/_panel$/, '_link')
          else
            onclick = "showTab(this, $('%s'))" % @show_tab
          end
          a_tag = content_tag :a, @label, :onclick => onclick, :class => @class, :style => @style, :id => @id
          if @default
            puts javascript_tag('defaultHash = "%s"' % @hash)
          end
        end
        puts content_tag(:li, a_tag, :class => 'tab')
        super
      end
    end

    sub_element Tabset::Tab

    def initialize(options={})
      super( {'class' => 'top'}.merge(options) )
    end

    def open
      super
      puts "<div style='height:1%'>" # this is to force hasLayout in ie
      puts "<ul class='tabset #{@options['class']}'>"
    end

    def close
      @elements.each {|e| raw_puts e}
      puts "<li></li></ul>"
      puts "</div>"
      super
    end

  end


  #### SIDETAB CLASSES ###############################################

  class Sidebar < Root

    class Link < Element
      element_attr :label, :link, :selected
      def close
        selected = 'active' if "#{@selected}" == "true"
        puts "<div class='sidelink #{selected}'>"
        if @label.any?
          puts "<a href='#{@link}'>#{@label}</a>"
        else
          puts @link
        end
        puts "</div>"
        super
      end
    end

    class Subsection < Element
      sub_element Sidebar::Link
      element_attr :label
      def close
        puts "<div class='sidesubsection'>"
        puts "<div class='sidelabel'>#{@label}</div>" if @label
        @elements.each {|e| raw_puts e}
        puts "</div>"
        super
      end
    end

    class Section < Element
      element_attr :label
      sub_element Sidebar::Link
      sub_element Sidebar::Subsection
      def close
        puts "<div class='sidesection'>"
        puts "<div class='sidehead'>#{@label}</div>" if @label
        @elements.each {|e| raw_puts e}
        puts "<div class='sidetail'></div>"
        puts "</div>"
        super
      end
    end

    sub_element Sidebar::Section

    def open
      super
    end

    def close
      @elements.each {|e| raw_puts e}
      super
    end

  end

  #### FORM CLASSES ###################################################

  class Form < Root
    def title(value)
      puts "<tr class='title #{first}'><td colspan='2'>#{value}</td></tr>"
    end

    def label(value="&nbsp;")
      @elements << indent("<tr class='label #{first}'><td colspan='2'>#{value}</td></tr>")
    end

    def spacer
      @elements << indent("<tr class='spacer'><td colspan='2'><div></div></td></tr>")
    end

    def heading(text)
      @elements << indent("<tr class='#{first}'><td colspan='2' class='heading'><h2>#{text}</h2></td></tr>")
    end

    def hidden(text)
      @elements << indent("<tr style='display:none'><td>#{text}</td></tr>")
    end

    def raw(text)
      @elements << indent("<tr><td colspan='2'>#{text}</td></tr>")
    end

    def open
      super
      puts "<table class='form'>"
      title(@options[:title]) if @options[:title]
    end

    def close
      @elements.each {|e| raw_puts e}
      puts "</table>"
      super
    end

    def first
      if @first.nil?
        @first = false
        return 'first'
      end
    end

#    class Section < Element
#      sub_element :row
#      def label(value)
#        puts "label(#{value})<br>"
#      end
#    end

    class Row < Element
      element_attr :info, :label, :label_for, :input, :id, :style, :classes

      def open
        super
        @options[:style] ||= :hang
      end

      def close
        @input ||= @elements.first.to_s
        if @options[:style] == :hang
          @label ||= '&nbsp;'
          labelspan = inputspan = 1
          #labelspan = 2 if @label and not @input
          #inputspan = 2 if @input and not @label
          puts "<tr class='row #{parent.first} #{@classes}' id='#{@id}' style='#{@style}'>"
          puts "<td colspan='#{labelspan}' class='label'><label for='#{@label_for}'>#{@label}</label></td>"
          if @input
            puts "<td colspan='#{inputspan}' class='input'>"
            puts @input
            if @info
              puts "<div class='info'>#{@info}</div>"
            end
            puts "</td>"
          end
          puts "</tr>"
        elsif @options[:style] == :stack
          if @label
            puts '<tr><td class="label">%s</td></tr>' % @label
          end
          puts '<tr class="%s">' % @options[:class]
          puts '<td class="input">%s</td>' % @input
          puts '<td class="info">%s</td>' % @info
          puts '</tr>'
        end
        super
      end

      class Checkboxes < Element
        def open
          super
          puts "<table>"
        end

        def close
          puts @elements.join("\n")
          puts "</table>"
          super
        end

        class Checkbox < Element
          element_attr :label, :input, :info

          def open
            super
          end

          def close
            id = @input.match(/id=["'](.*?)["']/).to_a[1] if @input
            label = content_tag :label, @label, :for => id
            puts tag(:tr, content_tag(:td, @input) + content_tag(:td, label))
            if @info
              puts tag(:tr, content_tag(:td, '&nbsp;') + content_tag(:td, @info, :class => 'info'))
            end
            super
          end
        end
        sub_element Form::Row::Checkboxes::Checkbox
      end
      sub_element Form::Row::Checkboxes

    end

    sub_element Form::Row

#    class Item < Element
#      element_attr :object, :field, :label
#      def to_s
#        "<label>#{@field} #{@label}</label>"
#      end
#    end

  end
end
