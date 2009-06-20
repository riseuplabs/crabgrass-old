class WikiPage < Page
  include PageExtension::RssData

  def title=(value)
    write_attribute(:title, value)
    write_attribute(:name, value.nameize) if value
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
