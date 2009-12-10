class Gallery < Page
  include PageExtension::RssData

  # A gallery is a collection of images, being presented to the user by a cover
  # page, an overview or a slideshow.
  # The GalleryController also supports downloading a specific Gallery as a ZIP
  # archive file.

  has_many :showings, :order => 'position', :dependent => :destroy
  has_many :images, :through => :showings, :source => :asset, :order => 'showings.position'

  def update_media_flags
    self.is_image = true
  end

  # Galleries currently do not support attachments.
  # hence #=> false
  def supports_attachments
    false
  end

  # the ultimate method to add an image to a gallery. `position' can be left
  # nil - it then gets determined by acts_as_list (i.e. put it into the last
  # position).
  #
  # The `asset' needs to respond `true' on Asset#is_image?, else an appropriate
  # ErrorMessage is raised. `Showing' creation might fail if the `asset' has not
  # been saved yet (i.e. new_record? #=> true).
  #
  # After adding the Asset, the given user's `updated' method is called to
  # announce that this gallery was updated by her.
  #
  # This method always returns true. On failure an error is raised.
  def add_image!(asset, user, position = nil)
    check_type!(asset)
    if asset.page
      raise PermissionDenied unless user.may?(:view, asset.page)
    else
      self.add_attachment! asset
    end
    Showing.create! :gallery => self, :asset => asset, :position => position
    reset_associations(asset)
    if user
      user.updated(self)
    end
    true
  end

  # like add_image!, but does not save the page. Used to build
  # the associations in memory when creating a new page.
  #def add_image(asset, position = nil)
  #  asset.showings.build(:gallery => self, :position => position)
  #end

  # Removes an image from this Gallery by destroying the associating Showing.
  # the Asset's associations are resetted, the return value is the one of
  # Showing#destroy
  def remove_image!(asset)
    showing = self.showings.detect{|showing| showing.asset_id == asset.id}
    showing.destroy
    if asset.is_attachment? and asset.page == self
      asset.destroy
    else
      reset_associations(asset)
    end
  end

  private

  # resets the associations of the given Asset, as well as the ones of this
  # Gallery. This is currently deactivated.
  def reset_associations(asset)
    #asset.showings.reset
    #asset.galleries.reset
    #self.showings.reset
    #self.images.reset
  end

#  def check_permissions!(asset, user)
#    unless user.may?(:view, asset)
#      raise PermissionDenied.new
#(I18n.t(:group_not_allowed_to_view_image_error))
#    end
#  end

  def check_type!(asset)
    raise ErrorMessage.new(I18n.t(:file_must_be_image_error)) unless asset.is_image?
  end

end
