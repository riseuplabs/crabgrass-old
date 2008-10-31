class AnnouncementPage < WikiPage

  before_create :set_flow
  def set_flow
    self.flow = FLOW[:announcement]
  end

  def title=(value)
    write_attribute(:title,value)
  end

end
