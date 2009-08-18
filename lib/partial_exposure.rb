# Developed March 17, 2008 by Chris Powers, Killswitch Collective http://killswitchcollective.com
# 
# This module hacks the render method so that every layout and partial is wrapped in an HTML comment. 
# Each comment displays the filename and path of each partial file and reveals exactly where it 
# starts and stops.
# 
# Just make sure you only use it in Development!
module PartialExposure
  
  def self.included(included_class)
    included_class.send(:alias_method_chain, :render, :partial_exposure)
  end

  def render_with_partial_exposure(options = {}, old_local_assigns = {}, &block)
    if options.is_a? Hash
      if options[:partial]
        out = "<!-- Begin Partial #{options[:partial]} -->\n"
        out << render_without_partial_exposure(options, old_local_assigns, &block).to_s
        out << "<!-- End Partial #{options[:partial]} -->\n"
        out
      elsif options[:file]
        out = "<!-- Begin Layout #{options[:file]} -->\n"
        out << render_without_partial_exposure(options, old_local_assigns, &block).to_s
        out << "<!-- End Layout #{options[:file]} -->\n"
        out
      else
        render_without_partial_exposure(options, old_local_assigns, &block)
      end
    else
      render_without_partial_exposure(options, old_local_assigns, &block)
    end
  end

end

ActionView::Base.send(:include, PartialExposure)