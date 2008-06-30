
class WikiPage < Page
     
  def title=(value)
    write_attribute(:title,value)
    write_attribute(:name,value.nameize)
  end
  
end
