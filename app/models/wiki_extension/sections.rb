module WikiExtension
  module Sections

    def all_sections
      # return [:document]
      structure.all_sections
    end

    def set_body_for_section(section, text)
      self.body = text
      # TODO: new_text += "\n\n" unless new_text =~ /\n\r?\n\r?\Z/

      return
      start_index = structure.section(section).start_index
      end_index = structure.section(section).end_index
      body[start_index..end_index] = text
    end
  end
end
