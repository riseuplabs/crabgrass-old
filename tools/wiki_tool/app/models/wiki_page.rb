
class WikiPage < Page
     
  def title=(value)
    write_attribute(:title, value)
    # don't set the name to duplicate name, because it won't have a real url
    if value and self.name.nil? and Page.find_by_name(value.nameize, :select => "name").nil?
      # no page exists with this name
      write_attribute(:name, value.nameize)
    end
  end

  # Return string of all tasks, for the full text search index
  def body_terms
    return "" unless data and data.body
    data.body
  end

  alias_method :wiki, :data

  before_save :update_wiki_group
  def update_wiki_group
    if self.group_name_changed?
      self.wiki.clear_html if self.wiki
    end
  end

end
