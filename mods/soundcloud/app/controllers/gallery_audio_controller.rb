class GalleryAudioController < ApplicationController

  permissions 'gallery'
  helper 'gallery'

  # make sure we have @page in authorized?
  prepend_before_filter :fetch_page

  def create
    @track = Track.create_for_page @page,
      :showing_id => params['track']['showing_id'],
      :asset_data => params['assets'].first
    if @track.new_record?
      flash_message_now :object => @track
    end
    redirect_to page_url(@page, :action => :edit)
  end

  def update
    @track = @page.tracks.find params['id']
    if @track.update_attributes(:asset_data => params['assets'].first)
      flash_message_now :title => I18n.t(:audio_updated),
                :success => I18n.t(:audio_updated_successfully)
    else
      flash_message_now :object => @track
    end
    redirect_to page_url(@page, :action => :edit)
  end

  def destroy
    @track = @page.tracks.find params['id']
    @track.destroy
    redirect_to page_url(@page, :action => :edit)
  end

  protected

  def fetch_page
    @page = Page.find params['page_id']
  end
end
