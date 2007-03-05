require 'wiki'

class Tool::Wiki < Page
  
  @@controller = 'wiki'
  @@model = Wiki
  @@icon = 'wiki.png'
  
  def new_tool
    self.tool = Wiki.new :body => 'new page'
  end
  
end
