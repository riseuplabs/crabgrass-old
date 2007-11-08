
#==============================================================================#
# sample7.rb
# $Id: sample7.rb,v 1.6 2002/11/19 09:46:43 rcn Exp $
#==============================================================================#

#==============================================================================#

require 'svg/svg'

#==============================================================================#

svg = SVG.new('4in', '4in', '0 0 400 400')

svg.define_style('.item0', SVG::Style.new(:fill => '#DDDDDD'))
svg.define_style('.item1', SVG::Style.new(:fill => '#BBBBBB'))
svg.define_style('.item2', SVG::Style.new(:fill => '#999999'))
svg.define_style('.item3', SVG::Style.new(:fill => '#777777'))
svg.define_style('.item4', SVG::Style.new(:fill => '#555555'))
svg.define_style('.item5', SVG::Style.new(:fill => '#333333'))

sum    = 0.0
radsum = 0.0
value  = (0..5).collect { rand(100) }.sort.reverse
value.each { |item| sum += item }
value.collect { |item|
  item.to_f / sum * 360
}.collect { |deg|
  deg * (Math::PI / 180)
}.each_with_index { |rad, index|
  cx = Math.sin(radsum) * 150 + 200
  cy = -Math.cos(radsum) * 150 + 200
  x  = Math.sin(radsum + rad) * 150 + 200
  y  = -Math.cos(radsum + rad) * 150 + 200

  path = ["M 200 200", "L #{cx.to_i} #{cy.to_i}", "A 150 150 0 #{if rad>Math::PI then 1 else 0 end} 1 #{x.to_i} #{y.to_i}", "z"]
  svg << SVG::Path.new(path) { self.class = "item#{index}" }

  radsum += rad
}

svg << SVG::Circle.new(200, 200, 150) { self.style = SVG::Style.new(:fill => 'none', :stroke => 'black') }

print svg.to_s

#==============================================================================#
#==============================================================================#
