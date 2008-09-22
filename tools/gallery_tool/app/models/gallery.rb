class Gallery < Page

  has_many :showings, :order => 'position', :dependent => :destroy
  has_many :images, :through => :showings, :source => :asset, :order => 'showings.position'

  def add_image!(asset, position = nil)
    check_permissions!(asset)
    check_type!(asset)
    Showing.create! :gallery => self, :asset => asset, :position => position
    reset_associations(asset)
    true
  end

  # like add_image!, but does not save the page. Used to build
  # the associations in memory when creating a new page.
  #def add_image(asset, position = nil)
  #  asset.showings.build(:gallery => self, :position => position)
  #end

  def remove_image!(asset)
    showing = self.showings.detect{|showing| showing.asset_id == asset.id}
    reset_associations(asset)
    showing.destroy
  end

  private
  
  def reset_associations(asset)
    #asset.showings.reset
    #asset.galleries.reset
    #self.showings.reset
    #self.images.reset
  end

  def check_permissions!(asset)
    if self.group and !self.group.may?(:view,asset.page)
      raise PermissionDenied.new('The group that owns this page is not allowed to view that image')
    end
  end

  def check_type!(asset)
    raise ErrorMessage.new('asset must be an image to be part of a gallery') unless asset.is_image?
  end

end
