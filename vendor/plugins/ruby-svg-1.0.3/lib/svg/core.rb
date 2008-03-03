
#==============================================================================#
# svg/core.rb
# $Id: core.rb,v 1.11 2003/02/06 14:59:43 yuya Exp $
#==============================================================================#

#==============================================================================#
# SVG Module
module SVG

  def self.new(*args)
    return Picture.new(*args)
  end

  #============================================================================#
  # Picture Class
  class Picture

    include ArrayMixin

    def initialize(width, height, view_box = nil)
      @width    = width
      @height   = height
      @x        = nil
      @y        = nil
      @view_box = view_box
      @title    = nil
      @desc     = nil

      @elements = []
      @styles   = []
      @scripts  = []
    end

    attr_reader   :elements, :styles, :scripts
    attr_accessor :width, :height, :x, :y, :view_box, :title, :desc

    def array
      return @elements
    end
    private :array

    def define_style(class_name, style)
      @styles << DefineStyle.new(class_name, style)
    end

    def to_s
      text  = %|<?xml version="1.0" standalone="no"?>\n|
      text << %|<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">\n|
      text << %|<svg width="#{@width}" height="#{@height}"|
      text << %| viewBox="#{@view_box}"| if @view_box
      text << %|>\n|

      @scripts.each { |script|
        text << script.to_s
      }

      unless @styles.empty?
        text << %|<defs>\n|
        text << %|<style type="text/css"><![CDATA[\n|
        text << @styles.collect { |define| define.to_s + "\n" }.join
        text << %|]]></style>\n|
        text << %|</defs>\n|
      end

      text << %|<title>#{@title}</title>\n| if @title
      text << %|<desc>#{@desc}</desc>\n|    if @desc
      text << @elements.collect { |element| element.to_s + "\n" }.join
      text << %|</svg>\n|
      return text
    end

    def svg
      return self.to_s
    end

    def svgz
      require 'zlib'
      return Deflate.deflate(self.to_s, Deflate::BEST_COMPRESSION)
    end

    def mime_type
      return 'image/svg+xml'
    end

  end # Picture

  #============================================================================#
  # DefineStyle Class
  class DefineStyle

    def initialize(class_name, style)
      @class_name = class_name
      @style      = style
    end

    attr_accessor :class_name, :style

    def to_s
      return "#{@class_name} { #{@style} }"
    end

  end # DefineStyle

  #============================================================================#
  # ECMAScript Class
  class ECMAScript

    def initialize(script)
      @script = script
    end

    attr_accessor :script

    def to_s
      text  = %|<script type="text/ecmascript"><![CDATA[\n|
      text << @script << "\n"
      text << %|]]></script>\n|
      return text
    end

  end # ECMAScript

  #============================================================================#
  # ECMAScriptURI Class
  class ECMAScriptURI

    def initialize(uri)
      @uri = uri
    end

    attr_accessor :uri

    def to_s
      return %|<script type="text/ecmascript" xlink:href="#{@uri}" />\n|
    end

  end # ECMAScriptURI

end # SVG

#==============================================================================#
#==============================================================================#
