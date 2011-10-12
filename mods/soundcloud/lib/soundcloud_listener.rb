class SoundcloudListener < Crabgrass::Hook::ViewListener
  include Singleton

  def admin_nav(context)
    render(:partial => '/admin/soundcloud_nav') if may_admin_site?
  end

  def edit_gallery_image_tabs(context = {})
    tabs = context[:tabs]
    tabs.tab do |tab|
      tab.label I18n.t :media_audio
      tab.show_tab 'audio-tab'
      tab.selected false
    end
  end

  def edit_gallery_image_content(context)
    render :partial => 'gallery_audio/edit'
  end

  def show_gallery_image_content(context)
    render :partial => '/gallery_audio/show'
  end

  def gallery_image_thumbnail(context = {})
    return unless image = context[:image]
    render :partial => '/gallery/audio_marker' if image.track
  end

end
