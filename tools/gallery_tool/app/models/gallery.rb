class Gallery < Page
  # A gallery is a collection of images, being presented to the user by a cover
  # page, an overview or a slideshow.
  # The GalleryController also supports downloading a specific Gallery as a ZIP
  # archive file.

  has_many :showings, :order => 'position', :dependent => :destroy
  has_many :images, :through => :showings, :source => :asset, :order => 'showings.position'

  # Galleries currently do not support attachments.
  # hence #=> false
  def supports_attachments
    false
  end
  
  # the ultimate method to add an image to a gallery. `position' can be left
  # nil - it then gets determined by acts_as_list (i.e. put it into the last
  # position).
  # If the given Asset doesn't have a AssetPage associated with it, this page 
  # gets created automatically, given that the `user' has the 
  # Before an Asset is added, the permissions for the given `user' are checked.
  # During this process PermissionDenied may be raised.
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
    check_for_page(asset, user)
    check_permissions!(asset, user)
    check_type!(asset)
    Showing.create! :gallery => self, :asset => asset, :position => position
    reset_associations(asset)
    if user
      user.updated(self)
    end
    true
  end

  # returns the result of `cover_showing.asset' or nil if `cover_showing' fails.
  def cover
    self.cover_showing ? self.cover_showing.asset : nil
  end
  
  # returns the Showing representing the current Gallery's cover.
  # This is either the one selected by a user (is_cover == true), the one with
  # acts_as_list position 0, or the first one in the list in case both of the
  # former ones fail.
  # If this Gallery does not have any `showings', this method will return nil.
  def cover_showing
    self.showings.find_by_is_cover(true) ||
      self.showings.find_by_position(0) ||
      self.showings.first
  end
  
  # Sets the cover of a Gallery to the given `image_id'. The `image_id' needs to
  # be either the `id' of a valid (i.e. saved to db) Asset or the Asset itself.
  # The appropriate Showing for the given Asset is fetched by the method itself.
  #
  # This method also steals the `is_cover' flag from the current holder.
  #
  # The return value is the one returned by Showing#save
  def cover=(image_id)
    showing = self.showings.find_by_asset_id(image_id.kind_of?(Asset) ? 
                                             image_id.id : image_id)
    raise ArgumentError unless showing
    old = self.cover_showing
    old.is_cover = false
    old.save
    showing.is_cover = true
    showing.save
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
    reset_associations(asset)
    showing.destroy
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

  def check_permissions!(asset, user)
    unless user.may?(:view,asset.page)
      raise PermissionDenied.new('The group that owns this page is not allowed to view that image'[:group_not_allowed_to_view_image_error])
    end
  end

  def check_type!(asset)
    raise ErrorMessage.new('File must be an image to be part of a gallery'[:file_must_be_image_error]) unless asset.is_image?
  end
  
  def check_for_page(asset, user)
    unless asset.page
      up=0
      gp=0
      page = AssetPage.create!(:title => asset.basename, :data => asset,
                                 :flow => FLOW[:gallery])
      self.group_participations.each do |gpart|
        page.group_participations.create(:group_id => gpart.group_id,
                                         :access => gpart.access)
        gp+=1
      end
      self.user_participations.each do |upart|
        page.user_participations.create(:user_id => upart.user_id,
                                        :access => upart.access)
        up+=1
      end
      page.save
      if user
        user.updated(page)
        page.save
      end
    end
  end

end
