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
  attr_accessor :parent

  def initialize(text=nil, name=nil, heading_level=nil, parent=nil)
    tree = super()
    tree.text = text
    tree.heading_level = heading_level
    tree.name = name
    tree.parent = parent
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
    self << GreenTree.new(txt, name, heading_level, self)
  end

  # returns the heading text for the one after the 'heading_name'
  def successor(heading_name)
    children.each_with_index do |node, i|
      if node.name == heading_name
        next_child = child(i+1)
        if self.parent.nil?
          return next_child
        else
          # go up a level to find the next element if we have to
          return next_child ? next_child : self.parent.successor(self.name)
        end
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
        puts "GREENCLOTH ERROR: Can't find heading with text: '#{text}' in markup"
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
  # this node in a body of greencloth text. it is a little iffy.
  # the text we have (self.text) has already been transformed by
  # greencloth (there is not a good way around this). So, we have
  # some transformed text, that we then need to match against original text.
  # yep, it is that ugly.
  def markup_regexp
    # take out carriage returns
    heading_text = Regexp.escape(self.text.gsub(/\r\n/, "\n"))

    # remove html entities, and let them match any character
    heading_text.gsub!(/&(\w{2,6}?|\\#[0-9A-Fa-f]{2,6});/,'.')

    # add back carriage returns as optional
    heading_text.gsub!('\\n', '\\r?\\n')

    Regexp.union(
      /^#{heading_text}\s*\r?\n[=-]+\s*?(\r?\n\r?\n?|$)/,
      /^h#{heading_level}\. #{heading_text}\s*?(\r?\n\r?\n?|$)/
    )
  end

end

