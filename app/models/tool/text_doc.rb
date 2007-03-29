
class Tool::TextDoc < Page

  before_save :assign_name

  controller 'wiki'
  model      Wiki
  icon       'text.png'
  tool_type  'wiki'
  
  #def initialize(*args)
  #  super(*args)
  #  self.data = Wiki.new :body => 'new page'
  #end
  
  private
  
  def assign_name
    self.name ||= find_unique_name(self.title)
    true
  end
  
end
