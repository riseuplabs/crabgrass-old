require 'iconv'

class String

  def nameize
    str = self.dup
    str.gsub!(/[^\w\+]+/, ' ') # all non-word chars to spaces
    str.strip!            # ohh la la
    str.downcase!         # upper case characters in urls are confusing
    str.gsub!(/\ +/, '-') # spaces to dashes, preferred separator char everywhere
    #str = "-#{s}" if str =~ /^(\d+)$/ # don't allow all numbers
    return str[0..49]
  end
  
  def denameize
    self.gsub('-',' ')
  end

  # returns false if any char is detected that is not allowed in
  # 'nameized' strings
  def nameized?
    self == self.nameize
  end
  
  def shell_escape
    if empty?
      "''"
    elsif self =~ %r{\A[0-9A-Za-z+_-]+\z}
      self
    else
      result = ''
      scan(/('+)|[^']+/) do
        if $1
          result << %q{\'} * $1.length
        else
          result << %Q{'#{$&}'}
        end
      end
      result
    end
  end

  #
  # replaces the symbols in a string
  # eg
  #  'I love {color} {thing}'.replace_symbols(:color => 'green', :thing => 'trees')
  # produces:
  #  'I love green trees'
  # 
  def percent_with_hash(hash)
    if hash.is_a? Hash
      str = self.dup
      hash.each do |key, value|
        str.gsub! /:#{key}/, value.to_s
        str.gsub! /\{#{key}\}/, value.to_s
      end
      str
    else
      percent_without_hash(hash)
    end
  end
  alias :percent_without_hash :%
  alias :% :percent_with_hash

end

