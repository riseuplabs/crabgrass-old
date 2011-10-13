class GalleryImageController < BasePageController
  before_filter :get_track, :only => [:show, :edit]

  protected

  def get_track
    get_image unless @showing
    @track = @showing.track
    if action?(:edit)
      @track ||= @showing.build_track
      @track_upload_id = (0..29).to_a.map {|x| rand(10)}.to_s
    end
  end

end
