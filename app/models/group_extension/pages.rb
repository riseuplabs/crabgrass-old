#
# Module that extends Group behavior.
#
# Handles all the group <> page relationships
#
module GroupExtension::Pages

  def self.included(base)
    base.instance_eval do
      has_many :participations, :class_name => 'GroupParticipation', :dependent => :delete_all
      has_many :pages, :through => :participations do
        def pending
          find(:all, :conditions => ['resolved = ?',false], :order => 'happens_at' )
        end
      end
    end     
  end

  #
  # build or modify a group_participation between a group and a page
  # return the group_participation object, which must be saved for
  # changes to take effect.
  # 
  def add_page(page, attributes)
    participation = page.participation_for_group(self)
    if participation
      participation.attributes = attributes
    else
      participation = page.group_participations.build attributes.merge(:page_id => page.id, :group_id => id)
    end
    page.group_id_will_change!
    page.association_will_change(:groups)
    return participation
  end

  def remove_page(page)
    page.groups.delete(self)
    page.group_id_will_change!
    page.association_will_change(:groups)
    page.group_participations.reset
  end
  
  def may?(perm, page)
    begin
       may!(perm,page)
    rescue PermissionDenied
       false
    end
  end
  
  # perm one of :view, :edit, :admin
  # this is still a basic stub. see User.may!
  def may!(perm, page)
    gparts = page.participation_for_groups(group_and_committee_ids)
    if gparts.any?
      part_with_best_access = gparts.min {|a,b|
        (a.access||100) <=> (b.access||100)
      }
      return ( part_with_best_access.access || ACCESS[:view] ) <= ACCESS[perm]
    else
      raise PermissionDenied.new
    end
  end

end

