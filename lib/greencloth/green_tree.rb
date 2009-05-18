##
## GreenTree -- a nested tree used for building the outline
##
class GreenTree < Array
  attr_accessor :heading_level
  attr_accessor :tree_level
  attr_accessor :text
  attr_accessor :name
  attr_accessor :markup_index
  attr_accessor :type

  def initialize(text=nil, name=nil, heading_level=nil)
    tree = super()
    tree.text = text
    tree.heading_level = heading_level
    tree.name = name
    tree
  end

  def inspect
    if leaf?
      %Q["#{text}"]
    else
      %Q["#{text||'root'}" -> [#{self.map{|i|i.inspect}.join(', ')}]]
    end
  end

  alias :to_s :inspect
  alias :leaf? :empty?
  alias :children= :concat
  alias :child :slice
  def children; self; end

  def add_child(txt, name, heading_level)
    self << GreenTree.new(txt, name, heading_level)
  end

  # returns the heading text for the one after the 'heading_name'
  def successor(heading_name)
    children.each_with_index do |node, i|
      if node.name == heading_name
        return child(i+1)
      elsif !node.leaf?
        found = node.successor(heading_name)
        return found unless found.nil? 
      end
    end
    return nil # not found
  end

  # walks tree, looking for a node that matches
  def find(name)
    children.each do |node|
      if node.name == name
        return node
      elsif !node.leaf?
        node = node.find(name)
        return node unless node.nil?
      end
    end
    return nil # not found
  end

  # get the list of all the available heading names in this tree
  # makes no guarantee about ordering
  def heading_names
    names = []
    names << self.name
    children.each do |child|
      names.concat child.heading_names
    end
    names.compact
  end

  # modifies markup
  # finds the location for each heading in the markup
  def prepare_markup_index!(markup)
    if self.text
      # find the first occurance of this node in the markup
      self.markup_index = markup.index(self.markup_regexp)
      if self.markup_index.nil?
        raise "GREENCLOTH ERROR: Can't find heading with text: '#{text}' in markup" 
      else
        # modify the markup, so that it will no longer match
        # the markup_regexp at this position
        markup[self.markup_index] = "\000"
      end
    else
      self.markup_index = 0
    end

    children.each do |node|
      node.prepare_markup_index!(markup)
    end
  end

  # returns a regexp that can be used to find the original markup for 
  # this node in a body of greencloth text.
  def markup_regexp
    heading_text = Regexp.escape(self.text)
    Regexp.union(
      /^#{heading_text}\s*\r?\n[=-]+\s*?(\r?\n\r?\n?|$)/,
      /^h#{heading_level}\. #{heading_text}\s*?(\r?\n\r?\n?|$)/
    )
  end

end

