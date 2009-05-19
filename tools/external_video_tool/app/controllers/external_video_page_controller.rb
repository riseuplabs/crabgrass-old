class ExternalVideoPageController < BasePageController
  def create
    @page_class = ExternalVideoPage
    if params[:cancel]
      return redirect_to(create_page_url(nil, :group => params[:group]))
    elsif request.post?
      begin
        @external_video = ExternalVideo.new(params[:external_video])
        unless @external_video.valid?
          flash_message_now :object => @external_video
          return
        end
        @page = @page_class.create!(params[:page].merge(
          :user => current_user,
          :share_with => params[:recipients],
          :access => params[:access],
          :data => @external_video
          ))
        redirect_to(page_url(@page))
      rescue Exception => exc
        @page = exc.record
        flash_message_now :exception => exc
      end
    else
      @page = build_new_page(@page_class)
    end
  end
end
