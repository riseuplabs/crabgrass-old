
#==============================================================================#
# svg/element.rb
# $Id: element.rb,v 1.14 2003/02/06 14:59:43 yuya Exp $
#==============================================================================#

#==============================================================================#
# SVG Module
module SVG

  #============================================================================#
  # ElementBase Class
  class ElementBase

    def initialize(&block)
      @id        = nil
      @style     = nil
      @class     = nil
      @transform = nil
      @attr      = nil

      if block_given?
        instance_eval(&block)
      end
    end

    attr_accessor :id, :style, :class, :transform, :attr

    def to_s
      text = ''
      text << %| id="#{@id}"|               if @id
      text << %| style="#{@style}"|         if @style
      text << %| class="#{@class}"|         if @class
      text << %| transform="#{@transform}"| if @transform
      text << %| #{@attr}|                  if @attr
      return text
    end

  end # ElementBase

  #============================================================================#
  # Group Class
  class Group < ElementBase

    include ArrayMixin

    def initialize
      super()
      @elements = []
    end

    attr_reader :elements

    def array
      return @elements
    end
    private :array

    def to_s
     text = %|<g|
     text << super()
     text << %|>\n|
     text << @elements.collect { |element| element.to_s + "\n" }.join
     text << %|</g>\n|
    end

  end # Group

  #============================================================================#
  # Anchor Class
  class Anchor < ElementBase

    include ArrayMixin

    def initialize(uri)
      super()
      @uri      = uri
      @elements = []
    end

    attr_accessor :uri
    attr_reader   :elements

    def array
      return @elements
    end
    private :array

    def to_s
     text = %|<a|
     text << super()
     text << %| xlink:href="#{@uri}">\n|
     text << @elements.collect { |element| element.to_s + "\n" }.join
     text << %|</a>\n|
    end

  end # Anchor

  #============================================================================#
  # Use Class
  class Use < ElementBase

    def initialize(uri)
      super()
      @uri      = uri
    end

    attr_accessor :uri

    def to_s
     text = %|<use|
     text << super()
     text << %| xlink:href="#{@uri}"/>\n|
    end

  end # Use

  #============================================================================#
  # Rect Class
  class Rect < ElementBase

    def initialize(x, y, width, height, rx = nil, ry = nil)
      super()

      @x      = x
      @y      = y
      @width  = width
      @height = height
      @rx     = rx
      @ry     = ry
    end

    attr_accessor :width, :height, :x, :y, :rx, :ry

    def to_s
      text = %|<rect width="#{@width}" height="#{@height}"|
      text << %| x="#{@x}"|   if @x
      text << %| y="#{@y}"|   if @y
      text << %| rx="#{@rx}"| if @rx
      text << %| ry="#{@ry}"| if @ry
      text << super()
      text << %| />|
      return text
    end

  end # Rect

  #============================================================================#
  # Circle Class
  class Circle < ElementBase

    def initialize(cx, cy, r)
      super()

      @cx = cx
      @cy = cy
      @r  = r
    end

    attr_accessor :cx, :cy, :r

    def to_s
      text = %|<circle cx="#{@cx}" cy="#{@cy}" r="#{@r}"|
      text << super()
      text << %| />|
      return text
    end

  end # Circle

  #============================================================================#
  # Ellipse Class
  class Ellipse < ElementBase

    def initialize(cx, cy, rx, ry)
      super()

      @cx = cx
      @cy = cy
      @rx = rx
      @ry = ry
    end

    attr_accessor :cx, :cy, :rx, :ry

    def to_s
      text = %|<ellipse cx="#{@cx}" cy="#{@cy}" rx="#{@rx}" ry="#{@ry}"|
      text << super()
      text << %| />|
      return text
    end

  end # Ellipse

  #============================================================================#
  # Line Class
  class Line < ElementBase

    def initialize(x1, y1, x2, y2)
      super()
      @x1 = x1
      @y1 = y1
      @x2 = x2
      @y2 = y2
    end

    attr_accessor :x1, :y1, :x2, :y2

    def to_s
      text = %|<line x1="#{@x1}" y1="#{@y1}" x2="#{@x2}" y2="#{@y2}"|
      text << super()
      text << %| />|
      return text
    end

  end # Line

  #============================================================================#
  # Polyline Class
  class Polyline < ElementBase

    def initialize(points)
      super()
      @points = points
    end

    attr_accessor :points

    def to_s
      text = %|<polyline points="#{@points.join(' ')}"|
      text << super()
      text << %| />|
      return text
    end

  end # Polyline

  #============================================================================#
  # Polygon Class
  class Polygon < ElementBase

    def initialize(points)
      super()
      @points = points
    end

    attr_accessor :points

    def to_s
      text = %|<polygon points="#{@points.join(' ')}"|
      text << super()
      text << %| />|
      return text
    end

  end # Polygon

  #============================================================================#
  # Image Class
  class Image < ElementBase

    def initialize(x, y, width, height, href)
      super()
      @x      = x
      @y      = y
      @width  = width
      @height = height
      @href   = href
    end

    attr_accessor :x, :y, :width, :height, :href

    def to_s
      text = %|<image|
      text << %| x="#{@x}"| if @x
      text << %| y="#{@y}"| if @y
      text << %| width="#{@width}"|
      text << %| height="#{@height}"|
      text << %| xlink:href="#{@href}"|
      text << super()
      text << %| />|
      return text
    end

  end # Image

  #============================================================================#
  # Path Class
  class Path < ElementBase

    def initialize(path, length = nil)
      super()
      @path   = path
      @length = length
    end

    attr_accessor :path, :length

    def to_s
      text = %|<path d="#{@path.join(' ')}"|
      text = %| length="#{@length}"| if @length
      text << super()
      text << %| />|
      return text
    end

  end # Path

  #============================================================================#
  # Text Class
  class Text < ElementBase

    def initialize(x, y, text)
      super()
      @x             = x
      @y             = y
      @text          = text
      @length        = nil
      @length_adjust = nil
    end

    attr_accessor :x, :y, :text, :length, :length_adjust

    def to_s
      svg =  %|<text|
      svg << %| x="#{@x}"|                        if @x
      svg << %| y="#{@y}"|                        if @y
      svg << %| textLength="#{@length}"|          if @length
      svg << %| lengthAdjust="#{@length_adjust}"| if @length_adjust
      svg << super()
      svg << %|>|
      svg << text
      svg << %|</text>|
      return svg
    end

  end # Text

  #============================================================================#
  # Verbatim Class
  class Verbatim

    def initialize(xml)
      @xml = xml
    end

    attr_accessor :xml

    def to_s
      return @xml
    end

  end # Verbatim

end # SVG

#==============================================================================#
#==============================================================================#
