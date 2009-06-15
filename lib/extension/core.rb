
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
  
  def to_sym
    return self
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
  def to_h(&block)
    Hash[*self.collect { |v|
      [v, block.call(v)]
    }.flatten]
  end

  def path
    join('/')
  end

  # an alias for self.compact.join(' ')
  def combine(delimiter = ' ')
    compact.join(delimiter)
  end

=begin
  # returns a copy of the hash with symbols
  def symbolize
    self.map {|i| 
      if(!i.nil? && P(i.respond_to?(m=:to_sym) || i.respond_to?(m=:symbolize)))
        m == :to_sym ? i.to_sym : i.symbolize
      else
        i
      end                 
    }
  end
=end  
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
  
=begin  
  # returns a copy of the hash with symbols
  def symbolize
    self.keys.inject({})  { |m, k|
      m[k.kind_of?(Hash) ? k.symbolize : (k.respond_to?(:to_sym) ? k.to_sym : k)] = ((v = v.to_sym    rescue nil) ||
                                                                                     (v = v.symbolize rescue nil) || v)
      m
    }
  end 
=end  
end

class Symbol
  # should do the same as sym.to_s.any?. symbols are never empty, hence #=> true
  def any?
    true
  end
end
