
module Formy
  class SimpleForm < Root

    def open
      super
      puts '<div class="simple_form">'
    end

    def close
      @elements.each {|e| raw_puts e}
      puts "</div>"
      super
    end

    class Row < Element
      element_attr :info, :label, :input

      def open
        super
      end

      def close
        if @label.is_a? Array
          @label, @label_for = @label
        end
        html = []
        html << "<p>"
        html << "<label for=\"#{@label_for}\">#{@label}</label><br/>"
        html << @input
        html << "</p>"
        puts html.join
        super
      end
    end

    sub_element Row

  end
end
