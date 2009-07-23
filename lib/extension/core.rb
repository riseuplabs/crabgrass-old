
#
# here is a file of hackish extends to core ruby. how fun and confusing.
# they provide some syntatic sugar which makes things easier to read.
#

class NilClass
  def any?
    false
  end

  def any
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
  
  def to_sym
    return self
  end
end

# A class that return nil for everything, and never complains.
# Used by Object#try().
class SilentNil
  include Singleton
  def method_missing(*args)
    nil
  end
end

class Object
  def cast!(class_constant)
    raise TypeError.new unless self.is_a? class_constant
    self
  end

  def respond_to_any? *args
    args.each do |arg|
      return true if self.respond_to? arg
    end
    false
  end
  
  #
  # Object#try() has been added to rails 2.3. It allows you to call a method on
  # an object in safe way that will not bomb out if the object is nil or the
  # method does not exist.
  #
  # This try is similar, but also accepts zero args or multiple args.
  # 
  # Examples:
  #
  #  1. @person.try(:name)
  #  2. @person.try.name
  #  3. @person.try(:name=, 'bob')
  #
  def try(method=nil, *args)
    if method.nil?
      self.nil? ? SilentNil.instance : self   
    elsif respond_to? method
      send(method, *args)
    else
      nil
    end
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
    self.collect{|a| [a.t, a.to_s] }
  end
  
  def any_in?(array)
    return (self & array).any?
  end

  # [1,2,3].to_h {|i| [i, i*2]}
  # => {1 => 2, 2 => 4, 3 => 6}
  def to_h(&block)
    Hash[*self.collect { |v|
      block.call(v)
    }.flatten]
  end

  def path
    join('/')
  end

  # an alias for self.compact.join(' ')
  def combine(delimiter = ' ')
    compact.join(delimiter)
  end

end


class Hash
  # returns a copy of the hash, limited to the specified keys
  def allow(*keys)
    keys = keys.first if keys.first.is_a? Array
    hsh = {}
    keys.each do |key|
      value = self[key] || self[key.to_s] || self[key.to_sym]
      hsh[key] = value if value
    end
    hsh
  end

  # returns a copy of the hash, without any of the specified keys
  def forbid(*keys)
    keys = keys.first if keys.first.is_a? Array
    hsh = self.clone
    keys.each do |key|
      hsh.delete(key); hsh.delete(key.to_s); hsh.delete(key.to_sym)
    end
    hsh
  end

end

class Symbol
  # should do the same as sym.to_s.any?. symbols are never empty, hence #=> true
  def any?
    true
  end
end
