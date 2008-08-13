
class WikiPage < Page
     
  def title=(value)
    write_attribute(:title,value)
    write_attribute(:name,value.nameize)
  end

  # Return string of all tasks, for the full text search index
  def index_data
    data.body if data
  end
  
end
