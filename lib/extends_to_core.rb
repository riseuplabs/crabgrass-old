#
# here is a file of hackish extends to core ruby. how fun and confusing.
# they provide some syntatic sugar which makes things easier to read.
#

class NilClass
  def any?
    false
  end
  
  # nil.to_s => ""
  def empty?
    true
  end
  
  # nil.to_s => 0
  def zero?
    true
  end

  def first
    nil
  end
  
  def each
    nil
  end
end

class Object
  def cast!(class_constant)
    raise TypeError.new unless self.is_a? class_constant
    self
  end
end

# taken from beast
# used to auto-format post body
ActiveRecord::Base.class_eval do
  def self.format_attribute(attr_name)
    class << self; include ActionView::Helpers::TagHelper, ActionView::Helpers::TextHelper, WhiteListHelper; end
    define_method(:body)       { read_attribute attr_name }
    define_method(:body_html)  { read_attribute "#{attr_name}_html" }
    define_method(:body_html=) { |value| write_attribute "#{attr_name}_html", value }
    before_save do |record|
      unless record.body.blank?
        record.body.strip!
        record.body_html = auto_link record.body.to_s do |text|
          truncate(text, 50)
        end
        record.body_html = white_list(RedCloth.new(record.body_html).to_html)
      end
    end
  end
  
  def dom_id
    [self.class.name.downcase.pluralize.dasherize, id] * '-'
  end
  
  # used by Page
  def self.class_attribute(*keywords)
    for word in keywords
      word = word.id2name
      module_eval <<-"end_eval"
      def self.#{word}(value=nil)
        @#{word.sub '?',''} = value if value
        @#{word.sub '?',''}
      end
      def #{word}
        self.class.#{word.sub '?',''}
      end
      end_eval
    end
  end

end
