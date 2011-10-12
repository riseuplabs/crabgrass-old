class GalleryAudioController < BasePageController

  permissions 'gallery'
  helper 'gallery'

  def create
    @showing = @page.showings.find params['track']['showing_id']
    @track = @showing.create_track :asset_data => params['assets'].first
    if @track.save
      @showing.save
    else
      flash_message_now :object => @track
    end
    redirect_to page_url(@page, :action => :edit)
  end

  def update
    @track = @page.tracks.find params['id']
    @showing = @track.showing
    @track.asset_data = params['assets'].first
    if @track.save
      flash_message_now :title => I18n.t(:audio_updated),
                :success => I18n.t(:audio_updated_successfully)
    else
      flash_message_now :object => @track
    end
    redirect_to page_url(@page, :action => :edit)
  end

  def destroy
    @showing = @page.showings.find params['showing_id']
    @showing.track.destroy
    @showing.save
    redirect_to page_url(@page, :action => :edit)
  end

  protected

  # we don't want any confusion with :create specific context from
  # BasePageController
  def context
    page_context
  end
end
