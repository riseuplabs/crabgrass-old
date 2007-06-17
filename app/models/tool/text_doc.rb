
class Tool::TextDoc < Page

  #before_save :assign_name
  
  controller 'wiki'
  model      Wiki
  icon       'wiki.png'
  class_display_name 'wiki'
  class_description 'A free-form text document.'
  class_group 'wiki'
   
  #def before_create
  #  self.name = self.title.nameize
  #  super()
  #end
  
  def title=(value)
    write_attribute(:title,value)
    write_attribute(:name,value.nameize)
    #name ||= value.nameize
  end
  
  #def validate_on_create
  #  self.name = self.title.nameize
  #  if group_ids.any?
  #    if name_taken?
  #      errors.add('title', 'is already taken')
  #    end
  #  end
  #end 
  
  private
  
  #def assign_name
    #self.name ||= find_unique_name(self.title)
  #  self.name ||= self.title.nameize
  #  true
  #end
  
end
