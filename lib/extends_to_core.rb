require 'iconv'

#
# here is a file of hackish extends to core ruby. how fun and confusing.
# they provide some syntatic sugar which makes things easier to read.
#

class NilClass
  def any?
    false
  end
  
  # nil.to_s => ""
  def empty?
    true
  end
  
  # nil.to_i => 0
  def zero?
    true
  end

  def first
    nil
  end
  
  def each
    nil
  end
end

class Object
  def cast!(class_constant)
    raise TypeError.new unless self.is_a? class_constant
    self
  end
end

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
    s.titleize
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
  #  'I love :color :thing'.replace_symbols(:color => 'green', :thing => 'trees')
  # produces:
  #  'I love green trees'
  #
  def replace_symbols(hash)
    if hash.is_a? Hash
      str = self.dup
      hash.each do |key, value|
        str.gsub! /:#{key}/, value.to_s
      end
      str
    else
      percent_without_hash(hash)
    end
  end
  alias :percent_with_hash :replace_symbols

  alias :percent :%
  alias_method_chain :percent, :hash
  alias :% :percent

end

class Array
  # creates an array suitable for options_for_select
  # ids are converted to strings, so the 'selected' argument should
  # be a string. 
  def to_select(field,id='id')
    self.collect { |x| [x.send(field).to_s,x.send(id).to_s] }
  end

  # creates an array suitable for options_for_select.
  # for use with arrays of single values where you want the
  # option shown to be localized.
  # eg ['hi','bye'] --> [['hi'.t,'hi'],['bye'.t,'bye']]
  def to_localized_select
    self.collect{|a| [a.t, a] }
  end
  
  def any_in?(array)
    return (self & array).any?
  end
  def to_h(&block)
    Hash[*self.collect { |v|
      [v, block.call(v)]
    }.flatten]
  end

  def path
    join('/')
  end
end

class Hash
  # returns a copy of the hash,
  # limited to the specified keys
  def allow(*keys)
    if keys.first.is_a? Array
      keys = keys.first
    end
    hsh = {}
    keys.each do |key|
      value = self[key] || self[key.to_s] || self[key.to_sym]
      hsh[key] = value if value
    end
    hsh
  end
end


