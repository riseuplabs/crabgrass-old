module WikiExtension
  module Sections

    def all_sections
      return [:document]
      structure.all_sections
    end

    def set_body_from_section(section, text)
      self.body = text
      return
      start_index = structure.section(section).start_index
      end_index = structure.section(section).end_index
      body[start_index..end_index] = text
    end
  end
end
