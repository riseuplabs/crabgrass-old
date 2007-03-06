
class Tool::TextDoc < Page
  controller 'wiki'
  model      Wiki
  icon       'text.png'
  tool_type  'wiki'
  
  def initialize(*args)
    super(*args)
    self.data = Wiki.new :body => 'new page'
  end
end
