# Copyright (c) 2009 Todd Willey <todd@rubidine.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module BeforeRenderInstance
  def self.included kls
    kls.send :alias_method_chain, :render, :before_render_filter
    kls.send :alias_method_chain, :render_to_string, :before_render_filter
  end

  def render_with_before_render_filter(options = nil, extra_options = {}, &block)
    run_before_render_filters
    rv = render_without_before_render_filter(options, extra_options, &block)
    return rv
  end

  # CRABGRASS:
  # skip filter on render_to_string 
  def render_to_string_with_before_render_filter(options=nil, &block)
    render_without_before_render_filter(options, &block)
  ensure
    erase_render_results
    forget_variables_added_to_assigns
    reset_variables_added_to_assigns
  end

  private
  def run_before_render_filters chain=self.class.filter_chain
    chain.select{|x| x.is_a?(ActionController::Filters::BeforeRenderFilter)}.each do |filter|
      filter.call(self)
    end
  end

end
