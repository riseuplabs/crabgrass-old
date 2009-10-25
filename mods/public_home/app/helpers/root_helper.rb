module RootHelper
  def titlebox_description_html
    if logged_in?
      @group.profiles.public.summary_html
    else
      welcome = h "Welcome to {site_title}"[:welcome_title, current_site.title]
      message = first_with_any(:welcome_login_message.t, :welcome_message.t)
      content_tag(:h1, welcome) <<
        format_text(message)
    end
  end

  def sidebar_top_partial
    if logged_in?
      'sidebox_top'
    else
      '/account/login_form_box'
    end
  end
end
