=begin

In development mode, rails is very aggressive about unloading and reloading
classes as needed. Unfortunately, for crabgrass page types, rails always gets
it wrong. To get around this, we create static proxy representation of the
classes of each page type and load the actually class only when we have to.

=end

class PageClassProxy

  attr_accessor :controller, :model, :icon, :controller_class_name
  attr_accessor :class_display_name, :class_description, :class_group
  attr_accessor :class_name, :full_class_name, :internal, :order, :short_class_name
  
#  cattr_accessor :quiet

  def initialize(arg=nil)
    if arg == nil
      ;
    elsif arg.is_a? Hash
      arg.each do |key,value|
        method = key.to_s + '='
        self.send(method,value) if self.respond_to?(method)
      end
      self.class_group = [self.class_group] unless self.class_group.is_a? Array
      self.full_class_name = self.class_name
      self.controller_class_name = "#{controller.camelcase}Controller"
    	#The names used in Site.available_page_types; inverse of class_name_to_class
      self.short_class_name = self.class_name.sub("Page","")
      self.order ||= 100
    else
      throw Exception.new('no longer used')
#      page_class_name = arg
#      self.class_name = page_class_name
#      self.full_class_name = "Tool::" + page_class_name
#      %w[controller icon class_display_name class_description class_group].each do |attri|
#        self.send(attri+'=',actual_class.send(attri))
#      end
#      self.model = actual_class.model.name if actual_class.model
#      self.controller_class_name = "Tool::#{controller.camelcase}Controller"
    end

  end

  def actual_class
    get_const(self.full_class_name)
  end

  # allows us to get constants that might be namespaced
  def get_const(str)
    str.split('::').inject(Object) {|x,y| x.const_get(y) }
  end

  def create(hash, &block)
    actual_class.create(hash, &block)
  end

  def create!(hash, &block)
    actual_class.create!(hash, &block)
  end

  def to_s
    full_class_name
  end

=begin
  def self.save_page_classes
    Dir.glob("#{RAILS_ROOT}/app/models/tool/*.rb").each do |toolfile|
      require toolfile
    end
    page_classes = Tool.constants.collect{|tool| PageClassProxy.new(tool) }
    File.open(filename,'w') do |f|
      f.write page_classes.to_yaml
    end
    puts "wrote #{filename}"
  end

  def self.load_page_classes
    if File.exists?(filename)
      YAML.load(File.new(filename)) + PageClassRegistrar.list
    elsif self.quiet != true
      puts "missing #{filename}. run 'rake update_page_classes'"
      exit
    end
  end

  def self.filename
    "#{RAILS_ROOT}/config/page_classes.yml"
  end
=end

end
