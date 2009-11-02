
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

#
# SilentNil
#
# A class that behaves like nil, but will not complain if you call methods on it.
# It just always returns more nil. Used by Object#try().
#
class SilentNil
  include Singleton
  def method_missing(*args)
    nil
  end
  def to_s
    ""
  end
  def inspect
    "nil"
  end
  def nil?
    true
  end
  def empty?
    true
  end
  def zero?
    true
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
  #
  #     this is useful if you are not sure if @person has .name() method.
  #     or if you think @person might be nil.
  #     similar to:
  #
  #       @person.name if @person and @person.respond_to?(:name)
  #
  #  2. @person.try.name
  #
  #     this is useful if you are not sure if @person is nil.
  #     however, this will still report an error if person is not nil, but
  #     person does not respond to 'name'.
  #     similar to:
  #
  #       @person.name if @person
  #
  #  3. @person.try(:name=, 'bob')
  #
  #     Same as usage #1, but with arguments.
  #
  #  4. @person.try(:flags).try[:status]
  #
  #     In other words, calls to try can be chained.
  #     This is similar to writing:
  #
  #       if @person and @person.respond_to?(:flags) and !@person.flags.nil?
  #         @person.flags[:status]
  #       end
  #
  # I heart syntax sugar.
  #
  def try(method=nil, *args)
    if method.nil?
      self.nil? ? SilentNil.instance : self
    elsif respond_to? method
      send(method, *args)
    else
      nil # we must return nil here and not SilentNil.instance, so that you can do
          # things like: object.try(:hi) || 'bye'
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
  # eg ['hi','bye'] --> [[I18n.t(:hi),'hi'],[I18n.t(:bye),'bye']]
  def to_localized_select
    self.collect{|a| [I18n.t(a.to_sym, :default => a.to_s), a] }
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

class TrueClass
  def any?
    true
  end
end

class FalseClass
  def any?
    false
  end
end

