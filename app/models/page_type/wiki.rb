require 'wiki'

class PageType::Wiki < Page
  
  @@controller = 'wiki'
  @@model = Wiki
  @@icon = 'wiki.png'
  @@type_name = 'wiki'
  
  def new_tool
    self.tool = Wiki.new :body => 'new page'
  end
  
end
