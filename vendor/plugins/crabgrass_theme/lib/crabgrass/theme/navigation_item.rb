##
## NAVIGATION ITEM
##
## A navigation item represents a single link in the navigation tree.
## As a tree, each item can have many children.
##

class Crabgrass::Theme::NavigationItem < Array

  attr_reader :name
  ATTRIBUTES = [:label, :url, :active, :visible, :html, :icon]

  def initialize(name, navdef)
    @name = name
    @navigation = navdef
    @pointer = 0
    @visible = true
  end

  def current
    self[@pointer]
  end

  def add(elem)
    push(elem)
    @pointer += 1
    elem
  end

  #
  # finds the element with the given name. does not decend the tree.
  # this is needed so that navigation definitions can add items to
  # pre-existing trees.
  #
  def seek(name)
    each_with_index do |elem, i|
      if elem.name == name
        @pointer = i
        return elem
      end
    end
    @pointer = length
    nil
  end

  #
  # used for debugging
  #
  def inspect
    "[#{@name}: #{collect {|i| i.inspect}.join(',')}]"
  end

  #
  # defines an attribute by creating the setting and getter methods needed.
  # raises an exception if the attribute is not in ATTRIBUTES.
  #
  def set_attribute(name, value)
    if !ATTRIBUTES.include?(name)
      raise 'ERROR in theme definition: "%s" is not a known attribute.' % name
    else
      instance_variable_set("@#{name}", value)
    end
  end
  
  #
  # define the getters for our attributes.
  # if the value of an attribute is a Proc, then we eval it in the context
  # of the controller.
  #
  ATTRIBUTES.each do |attr_name|
    attr_name = attr_name.to_s
    if attr_name =~ /\?$/
      attr_name.chop!
      define_method(attr_name + '?') do
        send(attr_name)
      end
    end
    define_method(attr_name) do
      value = instance_variable_get("@#{attr_name}")
      if value.is_a?(Proc) and @navigation.controller
        @navigation.controller.instance_eval(&value)
      else
        value
      end
    end
  end

  #
  # currently_active_item returns the first sub-tree that is currently active, if any.
  #
  def currently_active_item
    detect{|i| i.active && i.visible}
  end
end

