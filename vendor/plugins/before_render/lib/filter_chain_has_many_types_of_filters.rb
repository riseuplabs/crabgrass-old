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

module FilterChainHasManyTypesOfFilters

  def self.included kls
    kls.send :alias_method, :find_filter_append_position, :find_filter_append_positions_multitype
    kls.send :alias_method, :find_filter_prepend_position, :find_filter_prepend_positions_multitype
    kls.send :alias_method, :find_or_create_filter, :find_or_create_filter_multitype

    kls.send :cattr_accessor, :filter_order
    kls.filter_order = [
      :before,
      :around,
      :before_render,
      :after
    ]
  end

  private
  def map_filter_types_to_positions
    returning({}) do |rv|
      self.class.filter_order.each_with_index do |filter, idx|
        rv[filter] = idx
      end
    end
  end

  def find_filter_append_positions_multitype filters, filter_type
    positions = map_filter_types_to_positions
    i = 0
    pos = positions[filter_type]

    # shortcut the last type
    return -1 if (pos + 1) >= self.class.filter_order.length

    while self[i] and p2=positions[self[i].type] and p2 <= pos
      i += 1
    end
    i
  end

  def find_filter_prepend_positions_multitype filters, filter_type
    positions = map_filter_types_to_positions
    i = 0
    pos = positions[filter_type]

    # shortcut the first type
    return 0 if pos == 0

    while self[i] and p2=positions[self[i].type] and p2 < pos
      i += 1
    end
    i
  end

  def find_or_create_filter_multitype filter, filter_type, options={}
    update_filter_in_chain([filter], options)
    rv = find(filter){|f| f.type == filter_type}
    rv ||= filter_class(filter_type).new(filter_type, filter, options)
    rv
  end

  def filter_class filter_type
    "ActionController::Filters::#{filter_type.to_s.camelize}Filter".constantize
  rescue
    raise "Invalid filter class: ActionController::Filters::#{filter_type.to_s.camelize}Filter"
  end
end
