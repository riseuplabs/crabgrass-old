define_page_type :Gallery, {
  :controller => 'gallery',
  :icon => 'page_gallery',
  :class_group => ['media', 'media:image', 'collection'],
  :order => 30
}

extend_model :Asset do

  has_many :showings
  has_many :galleries, :through => :showings
  
  # update galleries after an image was saved which has galleries.
  # the updated_at column of galleries needs to be up to date to allow the
  # download_gallery action to find out if it's cached zips are up to date.
  #
  # hmm... i don't think this is a good idea. it will result in the Gallery page
  # being marked as updated in the recent pages feed, even when it has not been.
  # -elijah
  
  after_save :update_galleries
  def update_galleries
    if galleries.any?
      galleries.each { |g| g.save }
    end
  end

end


