##
## ThemeOptions - a simple class used to create a theme definitions
##

class Crabgrass::Theme::Options

  def initialize(theme)
    @theme = theme
    @namespace = []
  end

  # method calls with blocks push a new namespace
  # everything else just captures the first argument as the value.
  def method_missing(name, *args, &block)
    name = name.to_s
    if block
      @namespace.push(name)
      instance_eval(&block)
      @namespace.pop
    else
      key = (@namespace + [name]).join('_').to_sym
      value = args.first
      @theme.data[key] = value
    end
    nil
  end

  def html(*args, &block)
    key = (@namespace + ['html']).join('_').to_sym
    value = args.first || block
    @theme.data[key] = value
    nil
  end
  
  def var(variable_name)
    @theme.data[variable_name]
  end

end

