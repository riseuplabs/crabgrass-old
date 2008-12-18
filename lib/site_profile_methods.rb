# some handy methods to read profile settings easier

=begin

# PROFILE SETTINGS
# ----------------
# Basic Example:
#
#   profiles:
#     public:
#       visible_to: noone
#     private:
#       elements: []
#       visible_to: [peers, friends]
#
# This deactivates the public profile while the private profile is enabled, being
# visible to all peers and friends, however only showing the basic information.
#
# ELEMENTS
#
# The other elements can be enabled by adding them to the `elements' list.
#
# Example:
#   profiles:
#     public: [location, notes, email_addresses]
#
# The user now can enter his location, as well as multiple notes and email
# addresses in the public profile. If the singular form of an element is used,
# the user can only enter one value, with the plural form she can add as many as
# wanted.
#
# Currently the following fields are supported:
#  * email_address
#  * location
#  * note
#  * website
#  * phone_number
#  * crypt_key
#
# VISIBILITY
# 
# Profiles can be made visible to different groups being:
#  * noone (deactivated)
#  * everyone (everyone who visits the site)
#  * users (everyone who is logged in)
#  * peers (users that share a group with the person)
#  * friends (users being in the person's contact list)
#
# Obviously 'everyone' implies users, peers and friends, users implies peers and
# friends, however peers does not include friends, so that peers and friends
# may see different profiles of a person.
#
# You can specify either one, or multiple groups for the visible_by field.
#
# Example:
#
#   profiles:
#     public:
#       visible_to: users
#     private:
#       visible_to: [peers, friends]
#


  profiles:
    general_info: false
    public:
      elements: [note, location]
      visible_to: users
    private:
      elements: []
      visible_to: noone

=end

module SiteProfileMethods
  
  def self.included(base)
    base.class_eval do 
      def setup_profile_methods
        if !self.profiles
          raise Exception.new("Your site configuration is not up to date. You need to provide profile settings.")
        end
        @profiles.extend(ProfilesMethods)
        @profiles.public.extend(InstanceMethods)
        @profiles.private.extend(InstanceMethods)
      end
    end
  end
  
  module ProfilesMethods
    def public? 
      public.enabled?
    end
    
    def private?
      private.enabled?
    end
    
    def public
      self['public']
    end
    
    def private
      self['private']
    end
    
    def general_info?
      (self['general_info'] && self['general_info'] != 'false')
    end
  end
  
  module InstanceMethods
    def enabled?
      !visible_to?('noone')
    end
    
    def elements
      self['elements'].to_a
    end
    
    def visible_to
      self['visible_to'].to_a
    end
    
    def visible_to?(vis_group)
      alternatives = { 
        'users' => ['everyone'],
        'peers' => ['everyone','users'],
        'friends' => ['everyone','users']
      }
      vis_groups = (alternatives[vis_group] ?
                    alternatives[vis_group] << vis_group :
                    [vis_group])
      ret = false
      vis_groups.each do |vg|
        ret = visible_to.include?(vg)
        return ret if ret == true
      end
      return ret
    end
    
    def element?(element)
      self.elements.include?(element) ||
        self.multiple?(element)
    end
    
    def multiple?(element)
      self.elements.include?(element.pluralize)
    end
  end
end
