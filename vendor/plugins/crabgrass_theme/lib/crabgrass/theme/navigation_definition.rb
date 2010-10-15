##
## NAVIGATION DEFINITION
##

class Crabgrass::Theme::NavigationDefinition

  attr_accessor :controller

  def initialize
    @tree = Crabgrass::Theme::NavigationItem.new('root',self)
    @section_stack = []
    @section_stack << @tree
  end

  def method_missing(name, *args, &block)
    current = @section_stack.last
    if block
      current.set_attribute(name, block)
    else
      current.set_attribute(name, args.first)
    end
  end

  def section(name)
    current = @section_stack.last
    section = current.seek(name) || current.add(Crabgrass::Theme::NavigationItem.new(name,self))
    @section_stack.push(section)
      yield
    @section_stack.pop
  end

  alias :global_section :section
  alias :context_section :section
  alias :local_section :section

  def inspect
    @tree.inspect
  end

  def root
    @tree
  end

end
