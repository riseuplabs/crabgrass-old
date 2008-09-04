class Collection < Page
  has_many :collection_pages
  has_many :pages, :through => :collection_pages
end
