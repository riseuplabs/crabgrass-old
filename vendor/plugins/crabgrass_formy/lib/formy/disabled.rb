#  # sets up form keywords. when a keyword is called,
#  # it tries to call this method on the current form element.
#  def self.form_word(*keywords)
#    for word in keywords
#      word = word.id2name
#      module_eval <<-"end_eval"
#      def #{word}(options=nil,&block)
#        e = @@base.current_element.last
#        return unless e
#        unless e.respond_to? "#{word}"
#          @@base.puts "<!-- FORM ERROR: '" + e.classname + "' does not have a '#{word}' -->"
#          return
#        end
#        return e.#{word}(options,&block) if block_given?
#        return e.#{word}(options) if options
#        return e.#{word}()
#      end
#      end_eval
#    end
#  end

#  def url_to_hash(url)
#    path = url.to_s.split('/')[(3..-1)]
#    ActionController::Routing::Routes.recognize_path(path)
#  end

#    class Item < Element
#      element_attr :object, :field, :label
#      def to_s
#        "<label>#{@field} #{@label}</label>"
#      end
#    end

