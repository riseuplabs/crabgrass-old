module AccountHelper
  def welcome_title
    "Welcome to {site_title}"[:welcome_title, current_site.title]
  end

  def welcome_body
    site_string(:welcome_message)
  end
end
