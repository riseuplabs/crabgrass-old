module WikiExtension
  # this is used for aggregation, not for inclusion in Wiki model
  class WikiStructure
    attr_accessor :raw_structure

    def initialize(raw_structure)
      @raw_structure = raw_structure
    end
    
    def genealogy_for_section(section)
      [section]
    end
    
    def all_sections
      [:document]
    end

    protected

    def resolve_full_structure(raw_structure)
      @full_structure = @raw_structure
    end
  end
end