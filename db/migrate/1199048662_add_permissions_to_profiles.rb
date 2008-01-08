=begin

  every user or group has a number of different profiles.
  each profile is keyed to certain access. for example, you might
  have a profile for all your friends and a different one for all your enemies.
  in practice, the ui can determine how much detail you want to get into.
  in the core ui, there is (currently) only a distinction between public and
  private profiles.
  
  so, every user and group has a profile that determines what the current user
  can see. this migration adds to profiles not just stuff they can see,
  but also flags that determine what they can do and have access to.

  principles:
  
  (1) don't provide a false sense of privacy.
      in other words, don't give the option to hide information
      that can be figured out elsewhere.
      
=end

class AddPermissionsToProfiles < ActiveRecord::Migration
  def self.up

    ### ACCESS CHANGES ###

    add_column :profiles, :fof, :boolean   # friend of a friend

    ### ADDITIONAL PROFILE DATA ###
    
    add_column :profiles, :summary, :string
    add_column :profiles, :wiki_id, :integer
    add_column :profiles, :photo_id, :integer
    add_column :profiles, :layout_id, :integer  
    
    ### PERMISSIONS ###
    
    add_column :profiles, :may_see, :boolean
    # for groups:
    add_column :profiles, :may_see_committees, :boolean
    add_column :profiles, :may_see_networks, :boolean
    add_column :profiles, :may_see_members, :boolean
    add_column :profiles, :may_request_membership, :boolean
    add_column :profiles, :membership_policy, :integer
    # for users:
    add_column :profiles, :may_see_groups, :boolean
    add_column :profiles, :may_see_contacts, :boolean
    add_column :profiles, :may_request_contact, :boolean
    
    add_column :profiles, :may_pester, :boolean   # send page notification
    add_column :profiles, :may_burden, :boolean   # make admin/contributor of page
    add_column :profiles, :may_spy, :boolean      # know if you are logged in

    ActiveRecord::Base.record_timestamps = false
    Profile::Profile.reset_column_information    
    Profile::Profile.find(:all).each do |profile|
      profile.stranger = profile.all?
      profile.save!
    end
    
    Group.find(:all).each do |group|
      private_wiki = nil
      if group.private_home_id
        old_wiki = Wiki.find(group.private_home_id)
        private_wiki = Wiki.create :body => old_wiki.body 
        old_wiki.pages.first.destroy
      end
      profile = group.profiles.private
      profile.wiki = private_wiki
      profile.save!
      
      public_wiki = nil
      if group.public_home_id
        old_wiki = Wiki.find(group.public_home_id)
        public_wiki = Wiki.create :body => old_wiki.body
        old_wiki.pages.first.destroy
      end
      profile = group.profiles.public
      profile.may_see = group.read_attribute :publicly_visible_group
      profile.may_see_committees = group.read_attribute :publicly_visible_committees
      profile.may_see_members = group.read_attribute :publicly_visible_members
      profile.may_request_membership = group.read_attribute :accept_new_membership_requests
      profile.wiki = public_wiki
      profile.save!
    end
    
    remove_column :profiles, :all
    remove_column :profiles, :layout_type
    remove_column :profiles, :layout_data
    remove_column :groups, :publicly_visible_group
    remove_column :groups, :publicly_visible_committees
    remove_column :groups, :publicly_visible_members
    remove_column :groups, :accept_new_membership_requests
    remove_column :groups, :private_home_id
    remove_column :groups, :public_home_id
  end

  def self.down
    add_column :groups, :publicly_visible_group, :boolean
    add_column :groups, :publicly_visible_committees, :boolean
    add_column :groups, :publicly_visible_members, :boolean
    add_column :groups, :accept_new_membership_requests, :boolean
    add_column :groups, :private_home_id, :integer
    add_column :groups, :public_home_id, :integer
    
    Group.reset_column_information
    
    ActiveRecord::Base.record_timestamps = false
    Group.find(:all).each do |group|
      profile = group.profiles.public
      if profile
        group.write_attribute(:publicly_visible_group, profile.may_see?)
        group.write_attribute(:publicly_visible_committees, profile.may_see_committees?)
        group.write_attribute(:publicly_visible_members, profile.may_see_members?)
        group.write_attribute(:accept_new_membership_requests, profile.may_request_membership?)
        if profile.wiki and !group.committee?
          page = Page.make :wiki, :group => group, :name => 'public home', :body => profile.wiki.body
          page.save!
          group.public_home_id = page.data_id
        end
        profile.destroy
        group.save!
      end
      profile = group.profiles.private
      if profile
        if profile.wiki and !group.committee?
          page = Page.make :wiki, :group => group, :name => 'private home', :body => profile.wiki.body
          page.save!
          group.private_home_id = page.data_id
        end
        profile.destroy
        group.save!
      end
    end

    add_column :profiles, :all, :boolean
    Profile::Profile.reset_column_information
    Profile::Profile.find(:all).each do |profile|
      profile.all = profile.stranger?
      profile.save!
    end

    remove_column :profiles, :fof
    remove_column :profiles, :summary
    remove_column :profiles, :wiki_id
    remove_column :profiles, :photo_id
    remove_column :profiles, :may_see
    remove_column :profiles, :may_see_committees
    remove_column :profiles, :may_see_networks
    remove_column :profiles, :may_see_members
    remove_column :profiles, :may_see_contacts
    remove_column :profiles, :may_see_groups
    remove_column :profiles, :may_request_membership
    remove_column :profiles, :may_request_contact
    remove_column :profiles, :membership_policy
    remove_column :profiles, :may_pester
    remove_column :profiles, :may_burden
    remove_column :profiles, :may_spy 
    
    add_column :profiles, "layout_type", :string
    add_column :profiles, "layout_data", :text
    remove_column :profiles, :layout_id
  end
  
end
