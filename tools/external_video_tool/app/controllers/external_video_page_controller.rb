class ExternalVideoPageController < BasePageController
  def show
  end

  protected 

  def build_page_data
    external_video = ExternalVideo.new(params[:external_video])
  end
end
