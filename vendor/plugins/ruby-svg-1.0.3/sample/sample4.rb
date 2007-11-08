
#==============================================================================#
# sample4.rb
# $Id: sample4.rb,v 1.6 2002/11/19 10:15:34 rcn Exp $
#==============================================================================#

#==============================================================================#

require 'svg/svg'

#==============================================================================#

svg = SVG.new('4in', '4in', '0 0 400 400')

svg << SVG::Rect.new(0, 80, 400, 100) {
  self.style = SVG::Style.new(:fill => 'blue')
}

svg << SVG::Rect.new(0, 220, 400, 100) {
  self.style = SVG::Style.new(:fill => 'green')
}

svg << SVG::Circle.new(0, 200, 80) {
  self.style = SVG::Style.new(:fill => 'red', :fill_opacity => 0.2)
}

svg << SVG::Circle.new(100, 200, 80) {
  self.style = SVG::Style.new(:fill => 'red', :fill_opacity => 0.4)
}

svg << SVG::Circle.new(200, 200, 80) {
  self.style = SVG::Style.new(:fill => 'red', :fill_opacity => 0.6)
}

svg << SVG::Circle.new(300, 200, 80) {
  self.style = SVG::Style.new(:fill => 'red', :fill_opacity => 0.8)
}

svg << SVG::Circle.new(400, 200, 80) {
  self.style = SVG::Style.new(:fill => 'red', :fill_opacity => 1.0)
}

print svg.to_s

#==============================================================================#
#==============================================================================#
