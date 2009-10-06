#
# Handles creating an outline of the wiki body, and generating a table of contents
# from this data.
#
#

require File.dirname(__FILE__) + '/green_tree'

module GreenclothOutline

  # given a namized heading name (ie what is used for the anchor)
  # return all the containing text until the next heading of equal or higher level.
  def get_text_for_heading(heading_name)
    range = get_range_for_heading(heading_name)
    return nil unless range
    (self[range] || "").strip
  end

  # like get_text_for_heading, but allows you to replace that text with something
  # new and exciting.
  def set_text_for_heading(heading_name, new_text)
    node = heading_tree.find(heading_name)
    range = get_range_for_heading(heading_name)
    return self if range.nil?

    # enforce an empty trailing line (in case the text immediately after us is another heading)
    new_text += "\n\n" unless new_text =~ /\n\r?\n\r?\Z/

    # enforce a heading element, restore the old one if it was removed
    # new_text.insert(0, node.markup + "\n\n") unless new_text =~ /^h#{node.heading_level}\. .*?\n\r?\n\r?/
    # ^^^ I am not sure why i thought this was a good idea. I am leaving it disabled for now.

    # replace the text
    self[range] = new_text
    return self
  end

  def headings
    @headings
  end

  # some of the stuff from @headings doesn't make it
  # into the tree. this is a list of stuff that belogs to the tree
  def heading_names
    @heading_names ||= heading_tree.heading_names
  end

  def subheading_names(heading)
    node = heading_tree.find(heading)
    return [] unless node

    node.heading_names
  end

  def parent_heading_names(heading)
    node = heading_tree.find(heading)
    return [] unless node
    parent_headings = []

    heading_tree.children.each do |child|
      # this line of headings includes the one we're looking for
      if child.heading_names.include?(heading)
        # all the names that are the line from top to bottom
        # except the ones that are children of the heading we're
        # looking
        return child.heading_names - node.heading_names
      end
    end
    return []
  end

  # returns the tree of headings
  # if this is called after to_html, we use the already existing @headings
  # but be warned that to_html will mangled the string and it will not the
  # original!
  def heading_tree
    extract_headings unless @headings
    @heading_tree ||= convert_to_tree(@headings)
  end


  protected

  # returns the character index range starting with heading_name and continuing
  # until the next heading of equal or greater level, or the end of the string.
  def get_range_for_heading(heading_name)
    node = heading_tree.find(heading_name)
    return nil unless node

    # start_index = self.index(node.markup_regexp)
    start_index = node.markup_index

    return nil unless start_index

    next_node = heading_tree.successor(heading_name)
    if next_node
      # end_index = self.index(next_node.markup_regexp) - 1
      end_index = next_node.markup_index - 1

      return nil unless end_index
    else
      end_index = -1
    end

    start_index..end_index
  end

  # called by the formatter whenever it encounters h1..h4 tags
  def add_heading(indent,text)
    text = extract_offtags(text.dup)
    formatter.clean_html(text, {}) # strip ALL markup, modifies variable text.
    @headings ||= []
    @heading_names ||= {}
    if text
      name = text.nameize
      if @heading_names[name]
        name = find_available_name(@heading_names, name)
      end
      @heading_names[name] = true # mark as taken
      @headings << [indent, text, name]
    end
    return name
  end

  # called by greencloth when [[toc]] is encountered
  def symbol_toc
    if outline
      return '' if @headings.nil?
      tree = convert_to_tree(@headings)
      generate_toc_html(tree, 1)
    else
      "<p>[[toc]]</p>" # if outlining is disabled, pass through the macro text.
    end
  end

  private

  #
  # converts an array with heading numbers and values into a nested tree.
  #
  # INPUT:
  #   number = 1
  #   array = [[1, "Fruits"], [2, "Apples"], [2, "Pears"], [1, "Vegetables"], [2, "Green Beans"]]
  # OUTPUT:
  #
  # as a GreenTree:
  # "root" -> [
  #   "Fruits" -> ["Apples", "Pears"],
  #   "Vegetables" -> ["Green Beans"]
  # ]
  #
  # the old way, as an Array:
  # [
  #   ["Fruits", [
  #      ["Apples"],
  #      ["Pears"]
  #   ]],
  #   ["Vegetables",[
  #      ["Green Beans"]
  #   ]]
  # ]
  #
  def convert_to_tree(array)
    tree = convert_to_subtree(array, 1)
    tree.prepare_markup_index!(self.to_s)
    tree
  end

  # array: the flat array of detected headings
  # number: the current depth level
  def convert_to_subtree(array, number)
    result = GreenTree.new
    return result if array.nil? or array.empty?

    positions_of_number = find_positions_of_number(array,number) do |element|
      heading_number, text, name = element
      result.add_child(text, name, heading_number)
    end

    if positions_of_number.size == array.size
      return result # no more to do.
    elsif positions_of_number.empty?
      return convert_to_subtree(array, number+1) # search for lower level headings
    end

    # example data up to this point:
    #   positions_of_number = [0, 3]
    #   result = [["Fruits"], ["Vegetables"]]
    positions_of_number.each_with_index do |position, i|
      next_position = positions_of_number[i+1] || array.size
      # ex: (position+1)..(next_position-1) --> 1..2 or 4..4
      subarray = array[(position+1)..(next_position-1)]
      subtree = convert_to_subtree(subarray, number+1 )
      result.child(i).children = subtree if subtree.any?
    end
    result
  end

  # given:
  #   array = [[1, "Fruits"], [2, "Apples"], [2, "Pears"], [1, "Vegetables"], [2, "Green Beans"]]
  #   number = 1
  # results:
  #   [0, 3]
  def find_positions_of_number(array, number, &block)
    positions_of_number = []
    array.each_with_index {|element,i|
      if element[0] == number
        positions_of_number << i
        yield element
      end
    }
    return positions_of_number
  end

  # when there is a heading name collision, we must find a unique name for a heading
  def find_available_name(headings, original_name)
    i = 1
    name = original_name
    while headings[name]
      name = "#{original_name}_#{i+=1}"
    end
    return name
  end

  #  EXAMPLE TOC:
  #
  #  <ul class="toc">
  #    <li class="toc1"><a href="#fruits"><span>1</span> Fruits</a></li>
  #    <ul >
  #      <li class="toc2"><a href="#apples"><span>1.1</span> Apples</a></li>
  #      <ul >
  #        <li class="toc3"><a href="#green"><span>1.1.1</span> Green</a></li>
  #        <li class="toc3"><a href="#red"><span>1.1.2</span> Red</a></li>
  #      </ul>
  #      <li class="toc2"><a href="#pears"><span>1.2</span> Pears</a></li>
  #    </ul>
  #    <li class="toc1"><a href="#vegetables"><span>2</span> Vegetables</a></li>
  #    <ul >
  #      <li class="toc2"><a href="#turnips"><span>2.1</span> Turnips</a></li>
  #      <li class="toc2"><a href="#green-beans"><span>2.2</span> Green Beans</a></li>
  #    </ul>
  #  </ul>
  def generate_toc_html(tree, level, prefix='')
    html = ["<ul#{level == 1 ? ' class="toc"' : ''}>"]
    tree.children.each_with_index do |node,i|
      number = [prefix, i+1].join
      link = '<a href="#%s"><span>%s</span> %s</a>' % [node.name, number, node.text]
      html << '<li class="toc%i">%s</li>' % [level, link]
      html << generate_toc_html(node.children, level+1, number+'.') unless node.leaf?
    end
    html << "</ul>"
    html.join("\n")
  end

end
