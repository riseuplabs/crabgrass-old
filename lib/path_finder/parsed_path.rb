=begin

A simple class for parsing and generating 'readable url query paths'

=end

class PathFinder::ParsedPath < Array
  # return true if keyword is in the path
  def keyword?(word)
    detect do |e|
      e[0] == word
    end
  end
  
  # return the first argument of the pathkeyword
  # if:   path = "/person/23"
  # then: first_arg_for('person') == 23
  def first_arg_for(word)
    element = keyword?(word)
    return nil unless element
    return element[1]
  end
  alias :arg_for :first_arg_for
  
  def int_for(word)
    (arg_for(word)||0).to_i
  end
  
  def args_for(word)
    keyword?(word)
  end
  
  # returns true if arg is the value for a sort keyword
  # ie sort_arg('created_at') is true if path == /ascending/created_at
  def sort_arg?(arg)
    (keyword?('ascending') and first_arg_for('ascending') == arg) or (keyword?('descending') and first_arg_for('descending') == arg)
  end
  
  def remove_sort
    self.delete_if{|e| e[0] == 'ascending' or e[0] == 'descending' }
  end
  
  # converts this parsed path into a string path
  def to_s
    self.flatten.join('/')
  end
  
end

