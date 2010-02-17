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
# These methods get mixed into instances of ActionController::Base (by init.rb)
#
module BeforeRenderInstance
  def self.included kls
    kls.send :alias_method_chain, :render, :before_render_filter
  end

  ##
  # This rewrites the vanilla render() call to run all callbacks registered
  # with before_render method before actually rendering.
  #
  def render_with_before_render_filter *opts, &blk
    run_before_render_filters
    rv = render_without_before_render_filter(*opts, &blk)
    return rv
  end

  private
  def run_before_render_filters chain=self.class.filter_chain
    chain.select{|x| x.is_a?(ActionController::Filters::BeforeRenderFilter)}.each do |filter|
      filter.call(self)
    end
  end

end
