
#==============================================================================#
# sample3.rb
# $Id: sample3.rb,v 1.6 2002/11/19 10:15:34 rcn Exp $
#==============================================================================#

#==============================================================================#

require 'svg/svg'

#==============================================================================#

ruby_color = '#990000'
svg = SVG.new('4in', '4in', '0 0 400 400')

svg << SVG::Rect.new(76, 75, 248, 120) {
  self.style = SVG::Style.new
  self.style.fill         = '#FFFFFF'
  self.style.stroke       = ruby_color
  self.style.stroke_width = 2
}

svg << SVG::Rect.new(75, 195, 250, 120) {
  self.style = SVG::Style.new
  self.style.fill = ruby_color
}

svg << SVG::Text.new(200, 140, 'Ruby') {
  self.style = SVG::Style.new
  self.style.fill           = ruby_color
  self.style.font_size      = 100
  self.style.font_family    = 'serif'
  self.style.baseline_shift = 'sub'
  self.style.text_anchor    = 'middle'
}

svg << SVG::Text.new(200, 260, 'Ruby') {
  self.style = SVG::Style.new
  self.style.fill           = '#FFFFFF'
  self.style.font_size      = 100
  self.style.font_family    = 'serif'
  self.style.baseline_shift = 'sub'
  self.style.text_anchor    = 'middle'
}

print svg.to_s

#==============================================================================#
#==============================================================================#
