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
          record.body_html = GreenCloth.new(record.body,record.group_name).to_html(:no_enclosing_p)
        else
          record.body_html = GreenCloth.new(record.body).to_html(:no_enclosing_p)
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
      if table == 'page_views'
        stream.puts %(  execute "ALTER TABLE #{table} ENGINE = MyISAM")
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

