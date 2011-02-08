module RootHelper

  def configure_site_network_link
    if current_site.network and may_edit_group?(current_site.network)
      link_to_with_icon 'settings', I18n.t(:network_settings), groups_url(:action => 'edit', :id => current_site.network)
    end
  end

  def configure_site_link
    if may_admin_site?
      link_to_with_icon 'wrench', I18n.t(:administer_site), '/admin'
    end
  end

  def configure_site_appearance_link
    if current_site.custom_appearance and may_admin_site?
      link_to_with_icon 'color_wheel', I18n.t(:edit_appearance), edit_admin_custom_appearance_url(current_site.custom_appearance)
    end
  end

  def load_panel(panel_name, time_span=nil)
   remote_function(:url => {:controller => 'root', :action => panel_name, :time_span => time_span})
    #, :update => "#{panel_name}_panel")
  end

  def contribute_link
    if may_contribute_to_site?
      link_to_with_icon 'plus', I18n.t(:contribute_to_site), new_group_page_url(current_site.network)
    end
  end

  def create_group_link
    if may_create_group?
      link_to_with_icon 'membership_add', I18n.t(:create_a_group), '/groups/new'
    end
  end

  def welcome_box_link
    if params[:welcome_box]
      link_to_with_icon 'cancel', I18n.t(:hide_tips), '/'
    else
      link_to_with_icon 'weather_sun', I18n.t(:see_tips_to_get_started), '/?welcome_box=1'
    end
  end

  def home_sidebar_link_hook
    call_hook :home_sidebar
  end

  # the welcome_home_message key can be used to overwrite the message on site home.
  # This allows for translations of this message. If it is not set we fall back
  # to the site networks summary.
  def home_summary_html
    translation=I18n.t :welcome_home_message,
      :default => ( @group.profiles.public.summary || '' )
    format_text(translation)
  end

  def titlebox_description_html
    @group.profiles.public.summary_html
  end

  def sidebar_top_partial
    'sidebox_top'
  end

  def time_link_line(spinner_id)
    link_line(
      link_to_remote_active(
        I18n.t(:date_today),
        :url => url_for(:time_span => 'today'),
        :active => (params[:time_span] == 'today'),
        :loading => show_spinner(spinner_id)),
      link_to_remote_active(
        I18n.t(:date_this_week),
        :url => url_for(:time_span => 'this_week'),
        :active => (params[:time_span] == 'this_week'),
        :loading => show_spinner(spinner_id)),
      link_to_remote_active(
        I18n.t(:date_this_month),
        :url => url_for(:time_span => 'this_month'),
        :active => (params[:time_span] == 'this_month'),
        :loading => show_spinner(spinner_id)),
      link_to_remote_active(
        I18n.t(:date_all_time),
        :url => url_for(:time_span => 'all_time'),
        :active => (params[:time_span] == 'all_time' || params[:time_span].empty?),
        :loading => show_spinner(spinner_id))
    )
  end

  def type_link_line(spinner_id)
    links = []
    links.push link_to_remote_active(I18n.t(:all),
      :url => url_for(:type => nil),
      :active => params[:type].nil?,
      :loading => show_spinner(spinner_id))
    links += ['text','vote','media'].collect do |type|
      link_to_remote_active(
        display_page_class_grouping(type),
        :url => url_for(:type => type),
        :active => (params[:type] == type),
        :loading => show_spinner(spinner_id))
    end
    link_line(*links)
  end
end
