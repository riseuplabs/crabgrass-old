class ExternalVideoPageController < BasePageController
  session :off, :only => %w(rss)
  
  def create
    @page_class = ExternalVideoPage
    @stylesheet = 'page_creation'
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
          :share_with => Group.find_by_id(params[:group_id]),
          :access => :admin,
          :data => @external_video
          ))
        redirect_to(page_url(@page))
      rescue Exception => exc
        @page = exc.record
        flash_message_now :exception => exc
      end
    end
  end
  
  def rss
    if params[:id]
      @group = Group.get_by_name(params[:group])
      # treat invisible and nonexistent groups the same
      unless @group && @group.publicly_visible_group
        raise ErrorMessage.new("Invalid group #{params[:group]} specified")
      end
    end
    scope = @group ? ExternalVideo.visible_to(@group, :public) : ExternalVideo.visible_to(:public)
    @videos = scope.most_recent.find(:all, :limit => 20)
    render :layout => false
  end
end
