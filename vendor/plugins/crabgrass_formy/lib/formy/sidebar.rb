##
## SIDETAB CLASSES
##

module Formy

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

end
