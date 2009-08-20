module WikiExtension
  # this is used for aggregation, not for inclusion in Wiki model
  class WikiStructure
    attr_accessor :raw_structure
    attr_reader :full_structure

    def initialize(raw_structure)
      # require 'ruby-debug';debugger;1-1
      @raw_structure = raw_structure
      resolve_full_structure
    end

    # all parent and child elements for section
    def genealogy_for_section(section)
      [section]
    end

    def all_sections
      # [:document]
      collect_all_keys(full_structure)
    end

    protected

    def resolve_full_structure
      @full_structure = @raw_structure
    end

    def collect_all_keys(hash_with_children)
      keys = hash_with_children.keys
      hash_with_children.values.each do |value_hash|
        keys += collect_all_keys(value_hash[:children])
      end

      keys
    end
  end
end



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