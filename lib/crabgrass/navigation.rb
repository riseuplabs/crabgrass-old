class Navigation

  require "yaml"
  
  def initialize
    @structure = YAML.load_file([RAILS_ROOT, 'config', 'nav_structure.yml'].join('/'))
  end 

  def structure
    @structure
  end

end
