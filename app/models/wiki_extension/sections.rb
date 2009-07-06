module WikiExtension
  module Sections

    def all_sections
      structure.all_sections
    end

    def set_body_from_section(section, text)
      start_index = structure.section(section).start_index
      end_index = structure.section(section).end_index
      body[start_index..end_index] = text
    end
  end
end
