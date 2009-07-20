module WikiExtension
  # this is used for aggregation, not for inclusion in Wiki model
  class WikiStructure
    attr_accessor :raw_structure
    attr_reader :full_structure

    def initialize(raw_structure)
      # require 'ruby-debug';debugger;1-1
      # @raw_structure = wiki.raw_structure
      resolve_full_structure
    end

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