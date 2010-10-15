module Formy

  #### TAB CLASSES ##################################################

  class Tabset < Root
    class Tab < Element

      # required: label & ( link | url | show_tab | function)
      #
      # link     -- the a tag to put as the tab label.
      # url      -- the url to link the tab to
      # show_tab -- the dom_id of the div to show when the panel is clicked
      # function -- javascript to get called when the tab is clicked. may be used alone or
      #             in conjunction with show_tab or url (but not compatible with 'link' option)
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
      element_attr :label, :link, :show_tab, :url, :function, :selected, :icon, :id, :style, :class, :hash, :default

      def close
        selected = 'active' if "#{@selected}" == "true"
        @class = [@class, selected, ("small_icon #{@icon}_16" if @icon)].compact.join(' ')
        if @link
          a_tag = @link
        elsif @url
          a_tag = content_tag :a, @label, :href => @url, :class => @class, :style => @style, :id => @id, :onclick => @function
        elsif @show_tab
          if @show_tab =~ /_panel$/
            @hash ||= @show_tab.sub(/_panel$/, '').gsub('_','-')
            onclick = "showTab(this, $('%s'), '%s');" % [@show_tab, @hash]
            @id = @show_tab.sub(/_panel$/, '_link')
          else
            onclick = "showTab(this, $('%s'));" % @show_tab
          end
          if @function
            @function += ';' unless @function.ends_with(';')
            onclick = @function + onclick
          end
          a_tag = content_tag :a, @label, :onclick => onclick, :class => @class, :style => @style, :id => @id
          if @default
            puts javascript_tag('defaultHash = "%s"' % @hash)
          end
        elsif @function
          a_tag = content_tag :a, @label, :href => '#', :class => @class, :style => @style, :id => @id, :onclick => @function
        end
        puts content_tag(:li, a_tag, :class => 'tab')
        super
      end
    end

    sub_element Tabset::Tab

    def initialize(options={})
      super( {:type => :top}.merge(options) )
      @options[:separator] ||= "|"
    end

    def open
      super
      if @options[:type] == :simple
        puts "<ul class='tabset simple #{@options[:class]}'>"
      elsif @options[:type] == :top
        puts "<div style='height:1%'>" # this is to force hasLayout in ie
        puts "<ul class='tabset top #{@options[:class]}'>"
      else
        raise 'no such tabset type'
      end
    end

    def close
      if @options[:type] == :simple
        if @options[:separator].any?
          raw_puts @elements.join("<li> #{options[:separator]} </li>")
        else
          raw_puts @elements.join
        end
        puts "</ul>"
      elsif @options[:type] == :top
        @elements.each {|e| raw_puts e}
        puts "<li></li></ul>"
        puts "</div>"
      end
      super
    end

  end

end
