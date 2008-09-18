class Collection < Page
  has_many :links, :foreign_key => 'from'
  has_many :pages, :through => :links, :foreign_key => 'from'

  def add_page(page)
    self.pages << page
  end

end
