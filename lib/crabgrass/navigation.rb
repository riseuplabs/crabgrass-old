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
      structure.each_pair do |key, value|
        if value.is_a? Hash
          add Navigation.new(key, value)
        elsif !value.nil?
          content[key] = value
        end
      end
    else
      raise ArgumentError.new("wrong number of arguments (#{args.count} for 2)")
    end
  end

end
