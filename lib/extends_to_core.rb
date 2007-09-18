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
end

class Hash
  # returns a copy of the hash, limited to keys that are in the specified array
  def limit_keys_to(keys)
    reject{|key,value| !keys.include?(key)}
  end
end



