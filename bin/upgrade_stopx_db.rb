#
# Upgrades the stopx db to use sites.
#

super_admins = Group.find_by_name('site-admins')

network = Network.find_by_name 'stopx'

custom_appearance = CustomAppearance.create!

site = Site.create! :name => 'stopx', :title => 'Stop Exploitation', :domain => 'my.stopx.org', :limited => true, :network_id => network.id, :has_networks => false, :signup_mode => Conf::SIGNUP_MODE[:invite_only], :custom_appearance_id => custom_appearance.id

User.all.each {|user| network.add_user!(user) unless user.member_of?(network)}

GroupGainedUserActivity.destroy_all
GroupLostUserActivity.destroy_all

[Request, Activity, Group, Page].each do |model|
  model.connection.execute('UPDATE %s SET site_id = %s' % [model.table_name, site.id])
end

Page.delete_all 'type = "StaticPage"'

ThinkingSphinx.deltas_enabled = false
Page.all.each {|page| page.update_page_terms}

Asset.all.each do |asset|
  if asset.page_terms_id.nil? and asset.page and asset.page.page_terms
    Asset.connection.execute('UPDATE assets SET page_terms_id = %s WHERE id = %s' % [asset.page.page_terms.id, asset.id])
  end
end

