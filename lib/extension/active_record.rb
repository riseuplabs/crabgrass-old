#serialize_to and initialized_by were moved to lib/social_user.rb

ActiveRecord::Base.class_eval do

  # used to automatically apply greencloth to a field and store it in another field.
  # for example:
  #
  #    format_attribute :description
  #
  # Will save an html copy in description_html. This other column must exist
  #
  #    format_attribute :summary, :options => [:lite_mode]
  #
  # Will pass :lite_mode as an option to GreenCloth.
  #
  def self.format_attribute(attr_name, flags={})
    flags[:options] ||= []
    #class << self; include ActionView::Helpers::TagHelper, ActionView::Helpers::TextHelper, WhiteListHelper; end
    define_method(:body)       { read_attribute attr_name }
    define_method(:body_html)  { read_attribute "#{attr_name}_html" }
    define_method(:body_html=) { |value| write_attribute "#{attr_name}_html", value }
    before_save :format_body
    define_method(:format_body) {
      if body.any? and (body_html.empty? or (send("#{attr_name}_changed?") and !send("#{attr_name}_html_changed?")))
        body.strip!
        if respond_to?('owner_name')
          self.body_html = GreenCloth.new(body, owner_name, flags[:options]).to_html
        else
          self.body_html = GreenCloth.new(body, 'page', flags[:options]).to_html
        end
      end
    }
  end

  # used to give a default value to serializable attributes
  def self.serialize_default(attr_name, default_object)
    attr_name = attr_name.to_sym

    self.send :define_method, attr_name do
      read_attribute(attr_name) || write_attribute(attr_name, default_object.clone)
    end
  end

  def dom_id
    [self.class.name.downcase.pluralize.dasherize, id] * '-'
  end

  # make sanitize_sql public so we can use it ourselves
  def self.quote_sql(condition)
    sanitize_sql(condition)
  end
  def quote_sql(condition)
    self.class.quote_sql(condition)
  end


  # used by STI models to name fields appropriately
  # alias_attr :user, :object
  def self.alias_attr(new, old)
    if self.method_defined? old
      alias_method new, old
      alias_method "#{new}=", "#{old}="
      define_method("#{new}_id")   { read_attribute("#{old}_id") }
      define_method("#{new}_name") { read_attribute("#{old}_name") }
      define_method("#{new}_type") { read_attribute("#{old}_type") }
    else
      define_method(new) { read_attribute(old) }
      define_method("#{new}=") { |value| write_attribute(old, value) }
    end
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
# Crabgrass requires MyISAM for certain tables and the ability to add fulltext
# indexes. Additionally, since we are tied to mysql, we might as well be able
# to use it properly and specify the index length.
#
# These are not possible in the normal schema.rb file, so this little hack
# will insert the correct raw MySQL specific SQL commands into schema.rb
# in the following cases:
#
#  * if the index name matches /fulltext/, then the index is created as a
#    fulltext index and table is converted to be MyISAM.
#  * if the index name ends with a number, we assume this is the length of
#    the index. if the index is composite, then we assume there are multiple
#    length suffixes.
#    eg: idx_name_and_language_5_2 => CREATE INDEX ... (name(5),country(2))
#
module ActiveRecord
  class SchemaDumper #:nodoc:
    # modifies index support for MySQL full text indexes
    def indexes(table, stream)
      if table == 'page_views' or table == 'trackings'
        stream.puts %(  execute "ALTER TABLE #{table} ENGINE = MyISAM")
        stream.puts
      end
      indexes = @connection.indexes(table)
      indexes.each do |index|
        if index.name =~ /fulltext/ and @connection.is_a?(ActiveRecord::ConnectionAdapters::MysqlAdapter)
          stream.puts %(  execute "ALTER TABLE #{index.table} ENGINE = MyISAM")
          stream.puts %(  execute "CREATE FULLTEXT INDEX #{index.name} ON #{index.table} (#{index.columns.join(',')})")
        elsif index.name =~ /\d+$/ and @connection.is_a?(ActiveRecord::ConnectionAdapters::MysqlAdapter)
          lengths = index.name.match(/(_\d+)+$/).to_s.split('_').select(&:any?)
          index_parts = []
          index.columns.size.times do |i|
            if lengths[i] == '0'
              index_parts << index.columns[i]
            else
              index_parts << index.columns[i] + '(' + lengths[i] + ')'
            end
          end
          stream.puts %(  execute "CREATE INDEX #{index.name} ON #{index.table} (#{index_parts.join(',')})")
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

