require "yaml"
require "tree"

class Navigation < Tree::TreeNode

  def initialize(*args)
    case args.count
    when 0..1
      filename = args[0] || [RAILS_ROOT, 'config', 'nav_structure.yml'].join('/')
      structure = YAML.load_file filename
      initialize('/', structure)
    when 2
      name = args[0]
      structure = args[1]
      super(name, {})
      structure.try.each_pair do |key, value|
        if value.is_a? Hash or value.nil?
          add Navigation.new(key, value)
        else
          content[key] = value
        end
      end
    else
      raise ArgumentError.new("wrong number of arguments (#{args.count} for 2)")
    end
  end

  def level
    content['nav_level'] or
      isRoot? ? 0 : parent.level + 1
  end

  def outside_nav?
    content['outside_nav']
  end

  def path
    content['path'] or
      isRoot? ? '' : parent.path + '/' + path_name
  end

  def path_name
    content['path_name'] or
      name.gsub(' ', '_').underscore
  end

  def scope
    content['scope'] or
      !outside_nav? && "the level #{level} navigation" or
      'body'
  end

  def current_scope
    scope + ' .current'
  end

  def visit?
    content['visit'] or content['visit'].nil?
  end

  def id
    self.object_id
  end

  def self.column_names
    ['id','name', 'level', 'path']
  end

  # omg - this should be replaced with a proper implementation!
  def self.find *args
    id = case args.count
      when 1 then args.first
      when 2 then args[1][:conditions]['id']
      end
    ObjectSpace._id2ref(id)
  end
end
