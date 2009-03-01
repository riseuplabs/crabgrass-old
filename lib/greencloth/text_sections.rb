module GreenClothTextSections

  def extract_section_title(section_text)
    if /(^h[123]\.)(.*?$)(.*)/m =~ section_text
      # h1. style section
      title = $~[2]
    else
      title = section_text.split("\n").first.to_s
    end
  end

  def add_wiki_section_divs(input)
    html_sections = input.index_split(/<\s*h[123]/)

    start_div = "<div class=\"wiki_section\" id=\"wiki_section-%d\">\n"
    end_div = "\n</div>\n"

    section_index = 0
    output = ""

    html_sections.each do |section|
      output << start_div % section_index

      # indent lines
      lines = section.split("\n")
      lines.each {|l| output << "  " + l + "\n"}
      output.chomp!

      output << end_div
      section_index += 1
    end

    # strip the trailing newline from the last closing div
    output.chomp! if section_index > 0
    return output
  end

  # get all sections in an array
  def sections
    section_start_re = Regexp.union(GreenCloth::TEXTILE_HEADING_RE, GreenCloth::HEADINGS_RE)
    # get the sections
    sections = self.index_split(section_start_re)

    # cut out leading whitespace and newlines, but preserve white space on the first line with text
    sections[0] = sections[0].sub(/\A\s*\n/, '')

    # merge up the first section if it is all whitespace or empty
    if sections.size > 1 and sections.first =~ /\A\s*\Z/
      sections[1] = sections[0] + sections[1]
      sections.shift
    end

    return sections
  end

  module ClassMethods
    # returns true if +section+ starts with a section heading markup
    def is_heading_section?(section)
      section_start_re = Regexp.union(GreenCloth::TEXTILE_HEADING_RE, GreenCloth::HEADINGS_RE)
      return (section_start_re =~ section) == 0
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end
end
