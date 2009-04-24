module AccountHelper
  def welcome_title
    "Welcome to {site_title}"[:welcome_title, current_site.title]
#    if current_site and current_site.custom_appearance and !current_site.custom_appearance.welcome_text_title.empty?
#      current_site.custom_appearance.welcome_text_title
#    else
#      "Welcome to we.riseup.net"
#    end
  end

  def welcome_body
    site_string(:welcome_message)
#    if current_site and current_site.custom_appearance and !current_site.custom_appearance.welcome_text_body.empty?
#      current_site.custom_appearance.welcome_text_body
#    else
#      %Q{
#This site is powered by Crabgrass, a <a href="http://www.affero.org/oagpl.html">software libre</a> web application designed for group and network organizing, and tailored to the needs of the global justice movement. The long term goal is to provide the technical tools to facilitate active, confederal, and directly democratic social change networks. <a href="https://we.riseup.net/crabgrass/about">more »</a>
#        }
#    end
  end
end
