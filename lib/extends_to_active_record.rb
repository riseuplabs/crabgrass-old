ActiveRecord::Base.class_eval do
  
  # taken from beast
  # used to auto-format post body
  
  def self.format_attribute(attr_name)
    class << self; include ActionView::Helpers::TagHelper, ActionView::Helpers::TextHelper, WhiteListHelper; end
    define_method(:body)       { read_attribute attr_name }
    define_method(:body_html)  { read_attribute "#{attr_name}_html" }
    define_method(:body_html=) { |value| write_attribute "#{attr_name}_html", value }
    before_save do |record|
      unless record.body.blank?
        record.body.strip!
        record.body_html = GreenCloth.new(record.body).to_html
      end
    end
  end
  
  def dom_id
    [self.class.name.downcase.pluralize.dasherize, id] * '-'
  end
  
  # make sanitize_sql public so we can use it ourselves
  def self.public_sanitize_sql(condition)
    sanitize_sql(condition)
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

#
# validates_handle makes sure that 
# (1) the handle is in a good format
# (2) the handle is not taken by an existing group or user
# (3) the handle does not collide with our routes or controllers
# 

module ActiveRecord
  module Validations
    module ClassMethods
      def validates_handle(*attr_names)
        configuration = { :message => ActiveRecord::Errors.default_error_messages[:invalid], :on => :save, :with => nil }
        configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless value
            record.errors.add(attr_name, 'must exist')
            return
          end
          unless (3..50).include? value.length
            record.errors.add(attr_name, 'must be at least 3 and no more than 50 characters')
          end
          unless /^[a-z0-9]+([-_]*[a-z0-9]+){1,49}$/ =~ value
            record.errors.add(attr_name, 'may only contain letters, numbers, underscores, and hyphens')
          end
          if value =~ /^(groups|me|people|networks|places|avatars|page|pages|account|static|places)$/
            record.errors.add(attr_name, 'is already taken')
          end
          # TODO: make this dynamic so this function can be
          # used over any set of classes (instead of just User, Group)
          if record.instance_of? User
            if User.exists?(['login = ? and id <> ?', value, record.id])
              record.errors.add(attr_name, 'is already taken')
            end
            if Group.exists?({:name => value})
              record.errors.add(attr_name, 'is already taken')
            end
          elsif record.instance_of? Group
            if Group.exists?(['name = ? and id <> ?', value, record.id])
              record.errors.add(attr_name, 'is already taken')
            end
            if User.exists?({:login => value})
              record.errors.add(attr_name, 'is already taken')
            end
          end
        end
      end
    end   
  end
end
