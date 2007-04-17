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
  def to_select(field,id='id')
    self.collect { |x| [x.send(field),x.send(id)] }
  end
end

