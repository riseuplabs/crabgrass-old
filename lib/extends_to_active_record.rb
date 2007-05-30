ActiveRecord::Base.class_eval do
  
  # used to auto-format body  
  def self.format_attribute(attr_name)
    #class << self; include ActionView::Helpers::TagHelper, ActionView::Helpers::TextHelper, WhiteListHelper; end
    define_method(:body)       { read_attribute attr_name }
    define_method(:body_html)  { read_attribute "#{attr_name}_html" }
    define_method(:body_html=) { |value| write_attribute "#{attr_name}_html", value }
    before_save do |record|
      unless record.body.blank?
        record.body.strip!
        if record.respond_to?('group_name')
          record.body_html = GreenCloth.new(record.body,record.group_name).to_html
        else
          record.body_html = GreenCloth.new(record.body).to_html
        end
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
  
  # Used by Page subclasses to define themselved (ie icon, description, etc).
  # class_inheritable_accessor is very close to what we want. However, when
  # an attr is defined with class_inheritable_accessor, the accessor is not
  # called when it appears in a class definition, and I don't understand why.
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

  # this this should work, why not?
#  def self.class_attribute(*keywords)
#    for word in keywords
#      word = word.id2name
#      module_eval <<-"end_eval"
#        class << self
#          def #{word}(value=nil)
#            write_inheritable_attribute("#{word}", value) if value
#            read_inheritable_attribute("#{word}")
#          end
#          public :#{word}
#        end
#      end_eval
#    end
#  end

end


# It is nice to be able to have multiple submit buttons.
# For non-ajax, this works fine: you just check the existance
# in the params of the :name of the submit button.
# For ajax, this breaks, and is labelled wontfix
# http://dev.rubyonrails.org/ticket/3231
# this hack is an attempt to get around the limitation

class ActionView::Base
  alias_method :rails_submit_tag, :submit_tag
  def submit_tag(value = "Save changes", options = {})
    options[:id] = (options[:id] || options[:name] || :commit)
    options.update(:onclick => "Form.getInputs(this.form, 'submit').each(function(x) { if (x.value != this.value) x.name += '_not_pressed'; else x.name = x.name.gsub('_not_pressed','')}.bind(this))")
    rails_submit_tag(value, options)
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
            next #can't use return cause it raises a LocalJumpError
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
