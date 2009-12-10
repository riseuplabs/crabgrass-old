class WikiPage < Page
  include PageExtension::RssData

  def title=(value)
    write_attribute(:title, value)
    write_attribute(:name, value.nameize) if value
  end

  # for fulltext index
  def body_terms
    return "" unless data and data.body
    data.body
  end

  protected

  def wiki_with_auto_create(*args)
    wiki_without_auto_create(*args) or begin
      newwiki = Wiki.new do |w|
         w.user = User.current
         w.body = ""
      end
      self.data = newwiki
      save unless new_record?
      newwiki
    end
  end

  alias_method :wiki, :data
  alias_method_chain :wiki, :auto_create

  before_save :update_wiki_group
  def update_wiki_group
    if self.owner_name_changed?
      self.wiki.clear_html if self.wiki
    end
  end
end
