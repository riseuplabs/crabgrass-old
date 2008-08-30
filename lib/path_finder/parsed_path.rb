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

  # returns the search text, if any
  # ie returns "glorious revolution" if path == "/text/glorious+revolution"
  def search_text
    element = keyword? 'text'
    return nil unless element
    return element[1].gsub('+', ' ')
  end
  
  # returns true if arg is the value for a sort keyword
  # ie sort_arg('created_at') is true if path == /ascending/created_at
  def sort_arg?(arg=nil)
    if arg
      (keyword?('ascending') and first_arg_for('ascending') == arg) or (keyword?('descending') and first_arg_for('descending') == arg)
    else
      keyword?('ascending') or keyword?('descending')
    end
  end
  
  def remove_sort
    self.delete_if{|e| e[0] == 'ascending' or e[0] == 'descending' }
  end
  
  # converts this parsed path into a string path
  def to_s
    self.flatten.join('/')
  end
  
  # merge two parsed paths together.
  # for duplicate keywords use the ones in the path_b arg
  def merge(path_b)
    path_b = PathFinder::ParsedPath.new(path_b) unless path_b.is_a? PathFinder::ParsedPath
    path_a = self.dup
    path_a.remove_sort if path_b.sort_arg?
    (path_a + path_b).uniq
  end

end

