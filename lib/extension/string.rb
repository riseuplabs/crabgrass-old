require 'iconv'

class String

  def nameize
    translation_to   = 'ascii//ignore//translit'
    translation_from = 'utf-8'
    # Iconv transliteration seems to be broken right now in ruby, but
    # if it was working, this should do it.
    s = Iconv.iconv(translation_to, translation_from, self).to_s
    s.gsub!(/\W+/, ' ') # all non-word chars to spaces
    s.strip!            # ohh la la
    s.downcase!         # upper case characters in urls are confusing
    s.gsub!(/\ +/, '-') # spaces to dashes, preferred separator char everywhere
    s = "-#{s}" if s =~ /^(\d+)$/ # don't allow all numbers
    s
  end
  
  def denameize
    translation_from   = 'ascii//ignore//translit'
    translation_to     = 'utf-8'
    s = Iconv.iconv(translation_to, translation_from, self).to_s
    s.gsub('-',' ')
  end

  # returns false if any char is detected that is not allowed in
  # 'nameized' strings
  def nameized?
    self =~ /^[-a-z0-9_\+]+$/ and self =~ /-/
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

