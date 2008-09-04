#serialize_to and initialized_by were moved to lib/social_user.rb

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
  
  # class_attribute()
  #
  # Used by Page in order to allow subclasses (ie Tools) to define themselves
  # (ie icon, description, etc) by setting class attributes.
  #
  # <example>
  #   class Page
  #     class_attribute :color
  #   end
  #   class Wiki < Page
  #     color 'blue'
  #   end
  # </example>
  #
  # class_inheritable_accessor is very close to what we want. However, when
  # an attr is defined with class_inheritable_accessor, the accessor is not
  # called when it appears in a subclass definition, and I don't understand why.
  #
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

  # see http://blog.evanweaver.com/articles/2006/12/26/hacking-activerecords-automatic-timestamps/
  # only works because rails is not thread safe. 
  # but a thread safe version could be written.
  def without_timestamps
    self.class.record_timestamps = false
    yield
    self.class.record_timestamps = true
  end
end

# 
# What is going on here!?
# We have a table that needs to be MyISAM and it needs a fulltext index.
# This is not possible in the normal schema.rb file, so this little hack
# inserts the correct raw SQL to make it happen if there is an index
# with a name that matches /fulltext/
#
module ActiveRecord
  class SchemaDumper #:nodoc:
    # modifies index support for MySQL full text indexes
    def indexes(table, stream)
      indexes = @connection.indexes(table)
      indexes.each do |index|
        if index.name=~/fulltext/ and @connection.is_a?(ActiveRecord::ConnectionAdapters::MysqlAdapter)
          stream.puts %(  execute "ALTER TABLE #{index.table} ENGINE = MyISAM")
          stream.puts %(  execute "CREATE FULLTEXT INDEX #{index.name} ON #{index.table} (#{index.columns.join(',')})")
        else
          stream.print "  add_index #{index.table.inspect}, #{index.columns.inspect}, :name => #{index.name.inspect}"
          stream.print ", :unique => true" if index.unique
          stream.puts
        end
      end
      stream.puts unless indexes.empty?
    end
  end
end

class ActionView::Base

# It is nice to be able to have multiple submit buttons.
# For non-ajax, this works fine: you just check the existance
# in the params of the :name of the submit button.
# For ajax, this breaks, and is labelled wontfix
# http://dev.rubyonrails.org/ticket/3231
# this hack is an attempt to get around the limitation
# by disabling the other submit buttons, we ensure that their info
# doesn't end up in the params of the action.

  alias_method :rails_submit_tag, :submit_tag
  def submit_tag(value = "Save changes", options = {})
    #options[:id] = (options[:id] || options[:name] || :commit)
    options.update(:onclick => "Form.getInputs(this.form, 'submit').each(function(x){if (x!=this) x.disabled=true}.bind(this))")
    rails_submit_tag(value, options)
  end
  
# i really want to be able to use link_to(:id => 'group+name') and not have
# it replace '+' with some ugly '%2B' character.

  def link_to_with_pretty_plus_signs(*args)
    link_to_without_pretty_plus_signs(*args).sub('%2B','+')
  end
  alias_method_chain :link_to, :pretty_plus_signs
  
end

