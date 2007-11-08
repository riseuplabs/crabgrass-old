
#==============================================================================#
# svg/misc.rb
# $Id: misc.rb,v 1.6 2003/02/06 14:59:43 yuya Exp $
#==============================================================================#

#==============================================================================#
# SVG Module
module SVG

  #============================================================================#
  # Point Class
  class Point

    def initialize(x, y)
      @x = x
      @y = y
    end

    attr_accessor :x, :y

    def self.[](*points)
      if points.size % 2 == 0
        return (0...(points.size / 2)).collect { |i|
          self.new(points[i * 2], points[i * 2 + 1])
        }
      else
        raise ArgumentError, 'odd number args for Point'
      end
    end

    def to_s
      return "#{@x} #{@y}"
    end

  end # Point

  #============================================================================#
  # ArrayMixin Module
  module ArrayMixin

    include Enumerable

    def array
      raise NotImplementedError
    end
    private :array

    def [](index)
      array[index]
    end

    def []=(index, value)
      array[index] = value
    end

    def <<(other)
      array << other
    end

    def clear
      array.clear
    end

    def first
      array.first
    end

    def last
      array.last
    end

    def each(&block)
      array.each(&block)
    end

  end # ArrayMixin

end # SVG

#==============================================================================#
#==============================================================================#
