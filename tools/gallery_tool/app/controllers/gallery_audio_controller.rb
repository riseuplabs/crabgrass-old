class GalleryAudioController < BasePageController

  permissions 'gallery'
  helper 'gallery'

  def create
    @showing = @page.showings.find params['showing_id']
    @track = @showing.create_track params['track']
    @showing.save
  end

  def update
    @track = @page.tracks.find params['id']
    @showing = @track.showing
    if @track.update_attributes params['track']
      flash_message_now :title => I18n.t(:audio_updated),
                :success => I18n.t(:audio_updated_successfully)
    else
      flash_message_now :object => @track
    end
  end

  def destroy
    @showing = @page.showings.find params['showing_id']
    @showing.track.destroy
    @showing.save
  end

  protected

  # we don't want any confusion with :create specific context from
  # BasePageController
  def context
    page_context
  end
end
