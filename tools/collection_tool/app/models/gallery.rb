class Gallery < Collection
=begin
  # or maybe allow any page to be added to a gallery, and if it is not an 
  # image page, then the attachments to the page show up in the gallery instead?
  # not for now, maybe a future enhancement.
  def <<(page)
    raise TypeMismatch unless page.image?
    links.create(:page_id => page.id, :collection_id => self.id) # i don't know about the column names...
  end
=end
end
