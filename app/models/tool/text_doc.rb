
class Tool::TextDoc < Page

  #before_save :assign_name
  
  controller 'wiki'
  model      Wiki
  icon       'wiki.png'
  class_display_name 'wiki'
  class_description 'A free-form text document.'
  class_group 'wiki'
    
  def validate_on_create
    self.name = self.title.nameize
    if group_ids.any?
      if find_pages_with_name(name).any?
        errors.add('title', 'is already taken')
      end
    end
  end 
  
  private
  
  #def assign_name
    #self.name ||= find_unique_name(self.title)
  #  self.name ||= self.title.nameize
  #  true
  #end
  
end
