#
# Handles creating an outline of the wiki body, and generating a table of contents
# from this data.
#
# KNOWN BUGS:
# 
# (1) if two headings have the same name then there is a problem.
#
module GreenclothOutline

  # called by the formatter whenever it encounters h1..h4 tags
  def add_heading(indent,text)
    @headings ||= []
    @headings << [indent, text]
  end

  #
  # converts an array with heading numbers and values into a nested tree.
  #
  # INPUT:
  #   number = 1
  #   array = [[1, "Fruits"], [2, "Apples"], [2, "Pears"], [1, "Vegetables"], [2, "Green Beans"]]
  # OUTPUT:
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
  def convert_to_tree(array, number=1)
    return [] if array.nil? or array.empty?

    result = []
    positions_of_number = find_positions_of_number(array,number) do |value_at_position| 
      result << [value_at_position]
    end
    
    if positions_of_number.size == array.size
      return result # no more to do.
    elsif positions_of_number.empty?
      return convert_to_tree(array, number+1) # search for lower level headings
    end  

    # ex:  positions_of_number = [0, 3]
    #      result = [["Fruits"], ["Vegetables"]]
    positions_of_number.each_with_index do |position, i|
      next_position = positions_of_number[i+1] || array.size
      # ex: (position+1)..(next_position-1) --> 1..2 or 4..4
      subtree = convert_to_tree( array[(position+1)..(next_position-1)], number+1 ) 
      result[i][1] = subtree if subtree.any?
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
        yield element[1] #result << [element[1]]
      end
    }
    return positions_of_number
  end


=begin
  EXAMPLE TOC:

  <ul class="toc">
    <li class="toc1"><a href="#fruits"><span>1</span> Fruits</a></li>
    <ul >
      <li class="toc2"><a href="#apples"><span>1.1</span> Apples</a></li>
      <ul >
        <li class="toc3"><a href="#green"><span>1.1.1</span> Green</a></li>
        <li class="toc3"><a href="#red"><span>1.1.2</span> Red</a></li>
      </ul>
      <li class="toc2"><a href="#pears"><span>1.2</span> Pears</a></li>
    </ul>
    <li class="toc1"><a href="#vegetables"><span>2</span> Vegetables</a></li>
    <ul >
      <li class="toc2"><a href="#turnips"><span>2.1</span> Turnips</a></li>
      <li class="toc2"><a href="#green-beans"><span>2.2</span> Green Beans</a></li>
    </ul>
  </ul>

=end

  def symbol_toc
    return '' unless outline
    tree = convert_to_tree(@headings)
    generate_toc(tree, 1)
  end

  def generate_toc(tree, level, prefix='')
    html = ["<ul#{level == 1 ? ' class="toc"' : ''}>"]
    i = 0
    tree.each do |branch|
      text = branch[0]
      number = [prefix, (i+=1)].join
      link = '<a href="#%s"><span>%s</span> %s</a>' % [text.nameize, number, text]
      html << '<li class="toc%i">%s</li>' % [level, link]
      html << generate_toc(branch[1], level+1, number+'.') if branch[1]
    end
    html << "</ul>"
    html.join("\n")
  end

end

