class GalleryAudioController < BasePageController

  permissions 'gallery'
  helper 'gallery'

  # could we verify delete as the method on destry?
  verify :method => :post, :only => [:create]
  verify :method => [:post, :put], :only => [:update]
  verify :method => [:post, :delete], :only => [:destroy]

  def create
    @showing = Showing.find params['showing_id']
    @track = @showing.create_track params['track']
    @showing.save
  end

  def update
  end

  def destroy
  end

end
