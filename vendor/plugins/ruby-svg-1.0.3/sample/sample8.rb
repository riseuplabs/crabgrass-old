
#==============================================================================#
# sample8.rb
# $Id: sample8.rb,v 1.7 2002/11/19 10:15:34 rcn Exp $
#==============================================================================#

require 'svg/svg'

#==============================================================================#

svg = SVG.new('4in', '4in', '0 0 400 400')

svg.scripts << SVG::ECMAScript.new(<<-END_OF_SOURCE)
    function myHover(filterName, opavalue) {
        var filterOj  = document.getElementById('a1');
        var opacityOj = document.getElementById('t1');
        opacityOj.setAttribute("style", "opacity:" + opavalue);
//      filterOj.setAttribute("filter", "url(#" + filterName + ")")
    }
END_OF_SOURCE

svg << anc = SVG::Anchor.new('http://ruby-svg.sourceforge.jp/')

anc << SVG::Ellipse.new(90, 50, 30, 15) {
  self.id    = "a1"
  self.style = SVG::Style.new(:fill => 'none', :stroke => 'magenta', :stroke_width => '8')
  self.attr  = %|onmouseover="myHover('filter1', 1)" onmouseout="myHover('', 0.5)"|
}

anc << SVG::Text.new(65, 55, "Ruby/SVG") {
  self.id    = "t1"
  self.style = SVG::Style.new(:opacity => '0.5')
  self.attr  = %|onmouseover="myHover('filter1', 1)" onmouseout="myHover('', 0.5)"|
}

print svg.to_s

#==============================================================================#
#==============================================================================#
