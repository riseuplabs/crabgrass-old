
#==============================================================================#
# svg/style.rb
# $Id: style.rb,v 1.6 2003/02/06 14:59:43 yuya Exp $
#==============================================================================#

#==============================================================================#
# SVG Module
module SVG

  #============================================================================#
  # Style Class
  class Style

    Attributes = [
      'stroke',                      #
      'stroke-dasharray',            #
      'stroke-dashoffset',           #
      'stroke-linecap',              # round | butt | square | inherit
      'stroke-linejoin',             # round | bevel | miter | inherit
      'stroke-miterlimit',           #
      'stroke-opacity',              #
      'stroke-width',                #
      'fill',                        #
      'fill-opacity',                #
      'fill-rule',                   # evenodd | nonzero | inherit
      'alignment-baseline',          # auto | baseline | before-edge | text-before-edge | middle | after-edge | text-after-edge | ideographic | alphabetic | hanging | mathematical | inherit
      'baseline-shift',              # baseline | sub | super | <percentage> | <length> | inherit
      'direction',                   # ltr | rtl | inherit
      'dominant-baseline',           # auto | autosense-script | no-change | reset | ideographic | lower | hanging | mathematical | inherit
      'font',                        #
      'font-family',                 #
      'font-size',                   #
      'font-size-adjust',            # [0-9]+ | none | inherit
      'font-stretch',                # normal | wider | narrower | ultra-condensed | extra-condensed | condensed | semi-condensed | semi-expanded | expanded | extra-expanded | ultra-expanded | inherit
      'font-style',                  # normal | italic | oblique | inherit
      'font-variant',                # normal | small-caps | inherit
      'font-weight',                 # normal | bold | bolder | lighter | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 | inherit
      'glyph-orientation-hoizontal', # <angle> | inherit
      'glyph-orientation-vertical',  # auto | <angle> | inherit
      'kerning',                     # auto | <length> | inherit
      'letter-spacing',              # normal | <length> | inherit
      'text-anchor',                 # start | middle | end | inherit
      'text-decoration',             # none | underline | overline | line-through | blink | inherit
      'text-rendering',              # auto | optimizeSpeed | optimizeLegibility | geometricPrecision | inherit
      'unicode-bidi',                # normal | embed | bidi-override | inherit
      'word-spacing',                # normal | length | inherit
      'writing-mode',                # lr-tb | rl-tb | tb-rl | lr | rl  | tb | inherit
      'clip',                        # auto | rect(...) | inherit
      'clip-path',                   # <uri> | none | inherit
      'clip-rule',                   # evenodd | nonzero | inherit
      'color',                       #
      'color-interpolation',         # auto | sRGB | linearRGB | inherit
      'color-rendering',             # auto | optimizeSpeed | optimizeQuality | inherit
      'cursor',                      # [ [<uri> ,]* [ auto | crosshair | default | pointer | move | e-resize | ne-resize | nw-resize | n-resize | se-resize | sw-resize | s-resize | w-resize| text | wait | help ] ] | inherit
      'display',                     # inline | none | inherit
      'enable-background',           # accumulate | new [ ( <x> <y> <width> <height> ) ] | inherit
      'filter',                      # <uri> | none | uri
      'image-rendering',             # auto | optimizeSpeed | optimizeQuality
      'marker',                      #
      'marker-end',                  # none | <uri>
      'marker-mid',                  #
      'marker-start',                #
      'mask',                        #
      'opacity',                     #
      'overflow',                    # visible | hidden | scroll  | auto | inherit
      'pointer-events',              # visiblePainted | visibleFill | visibleStroke | visible | painted | fill | stroke | all | none | inherit
      'rendering-intent',            # auto | perceptual | relative-colorimetric | saturation | absolute-colorimetric | inherit
      'shape-rendering',             # auto | optimizeSpeed | crispEdges|geometricPrecision | inherit
      'visibility',                  # visible | hidden | collapse | inherit
    ]

    def initialize(attr = nil)
      @attributes = {}

      if attr && attr.kind_of?(Hash)
        attr.each { |key, value|
          @attributes[key.to_s.gsub(/_/, '-')] = value
        }
      end
    end

    Attributes.each { |attr|
      name = attr.gsub(/-/, '_')
      class_eval(<<-EOS)
        def #{name}
          return @attributes['#{attr}']
        end
        def #{name}=(value)
          @attributes['#{attr}'] = value
        end
      EOS
    }

    def to_s
      text = @attributes.select { |key, value|
        !value.nil?
      }.sort { |(a_key, a_value), (b_key, b_value)|
        a_key <=> b_key
      }.collect { |key, value|
        "#{key}: #{value};"
      }.join(' ')

      return text
    end

  end # Style

end # SVG

#==============================================================================#
#==============================================================================#
