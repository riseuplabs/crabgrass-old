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

##
#
# BeforeRender provides a callback chain that runs in the time between when the
# controller method completes and the render method is invoked.  It can be used
# to prepare variables for common view options (headers/footers/sidebars) in
# a DRY manner.
#
module BeforeRender

  ##
  # Adding filters to this will run them after the controller action completes
  # and before the view logic is invoked.
  #
  # This is the same sort of call chain as after filter, but after_filter runs
  # after the view is complete as well, whereas this runs before the rendering
  # but after the controller logic.
  #
  def append_before_render_filter *filters, &block
    filter_chain.append_filter_to_chain(filters, :before_render, &block)
  end

  def prepend_before_render_filter *filters, &block
    filter_chain.prepend_filter_to_chain(filters, :before_render, &block)
  end

  alias :before_render_filter :append_before_render_filter
  alias :before_render :append_before_render_filter

  def skip_before_render_filter *filters
    filter_chain.skip_filter_in_chain(*filters, &:before_render?)
  end

  def before_render_filters
    filter_chain.select(&:before_render?).map(&:method)
  end

end
