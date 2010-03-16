class ReplaceMeDashboardInSiteRedirectUrls < ActiveRecord::Migration

  @@redirects = ['signup_redirect_url', 'login_redirect_url']

  def self.up
    Site.find(:all).each do |site|
      @@redirects.each do |redirect| 
        if site.read_attribute(redirect) =~ /\/me\/dashboard\/?/
          site.update_attribute(redirect, '/me/pages/my_work')
        end
      end
    end
  end

  def self.down
    Site.find(:all).each do |site|
      @@redirects.each do |redirect|
        if site.read_attribute(redirect) =~ /\/me\/pages\/my_work\/?/
          site.update_attribute(redirect, '/me/dashboard')
        end
      end
    end
  end
end
