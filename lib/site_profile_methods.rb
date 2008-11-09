# some handy methods to read profile settings easier

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
