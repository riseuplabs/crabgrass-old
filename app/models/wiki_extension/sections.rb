module WikiExtension
  module Sections

    def all_sections
      structure.all_sections
    end

    def set_body_for_section(section, text)
      updated_body = structure.update_body(section, text)
      self.body = updated_body
      # TODO: new_text += "\n\n" unless new_text =~ /\n\r?\n\r?\Z/
    end
  end
end


#
# # given a namized heading name (ie what is used for the anchor)
# # return all the containing text until the next heading of equal or higher level.
# def get_text_for_heading(heading_name)
#   range = get_range_for_heading(heading_name)
#   return nil unless range
#   (self[range] || "").strip
# end
#
# # like get_text_for_heading, but allows you to replace that text with something
# # new and exciting.
# def set_text_for_heading(heading_name, new_text)
#   node = heading_tree.find(heading_name)
#   range = get_range_for_heading(heading_name)
#   return self if range.nil?
#
#   # enforce an empty trailing line (in case the text immediately after us is another heading)
#   new_text += "\n\n" unless new_text =~ /\n\r?\n\r?\Z/
#
#   # enforce a heading element, restore the old one if it was removed
#   # new_text.insert(0, node.markup + "\n\n") unless new_text =~ /^h#{node.heading_level}\. .*?\n\r?\n\r?/
#   # ^^^ I am not sure why i thought this was a good idea. I am leaving it disabled for now.
#
#   # replace the text
#   self[range] = new_text
#   return self
# end
