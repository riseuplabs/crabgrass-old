
#==============================================================================#
# sample6.rb
# $Id: sample6.rb,v 1.6 2002/11/19 10:15:34 rcn Exp $
#==============================================================================#

#==============================================================================#

require 'svg/svg'

#==============================================================================#

svg = SVG.new('4in', '4in', '0 0 400 400')

baseline_group = SVG::Group.new { self.style = SVG::Style.new(:fill => 'none', :stroke => '#CCCCCC', :stroke_width => 1) }
20.step(380, 20) { |i|
  baseline_group << SVG::Line.new(20, i, 380, i)
  baseline_group << SVG::Line.new(i, 20, i, 380)
}
svg << baseline_group

scaleline_group = SVG::Group.new { self.style = SVG::Style.new(:fill => 'none', :stroke => '#333333', :stroke_width => 2) }
scaleline_group << SVG::Line.new(20, 20, 20, 380)
scaleline_group << SVG::Line.new(20, 380, 380, 380)
svg << scaleline_group

points1 = (0..18).collect { |i| SVG::Point.new(i * 20 + 20, 380 - i ** 2) }
points2 = (0..18).collect { |i| SVG::Point.new(i * 20 + 20, 380 - i * 10) }
points3 = (0..18).collect { |i| SVG::Point.new(i * 20 + 20, 380 - (Math.sin(i.to_f / 10) * 300).to_i) }

svg << SVG::Polyline.new(points1) { self.style = SVG::Style.new(:fill => 'none', :stroke => '#CC0000', :stroke_width => 3, :stroke_opacity => 0.6) }
svg << SVG::Polyline.new(points2) { self.style = SVG::Style.new(:fill => 'none', :stroke => '#009900', :stroke_width => 3, :stroke_opacity => 0.6) }
svg << SVG::Polyline.new(points3) { self.style = SVG::Style.new(:fill => 'none', :stroke => '#0000CC', :stroke_width => 3, :stroke_opacity => 0.6) }

print svg.to_s

#==============================================================================#
