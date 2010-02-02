class Navigation

  require "yaml"

  def structure
    YAML.load_file([RAILS_ROOT, 'config', 'nav_structure.yml'].join('/'))
  end

end
