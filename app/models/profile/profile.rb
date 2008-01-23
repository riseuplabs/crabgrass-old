=begin

A person or group profile

Every person or group can have many profiles, each with different permissions
and for different languages. A given user will only see one of these profiles,
the one that matches their language and relationship to the user/group.

Order of profile presidence (user sees the first one that matches):
 (1) foe
 (2) friend   } the 'private' profile
 (3) peer     \  might see 'private' profile
 (4) fof      /  or might be see 'public' profile
 (5) stranger } the 'public' profile

=end

class Profile::Profile < ActiveRecord::Base

  ### relationship to user or group #########################################
  
  belongs_to :entity, :polymorphic => true
  def user; entity; end
  def group; entity; end
    
  before_create :fix_polymorphic_single_table_inheritance
  def fix_polymorphic_single_table_inheritance
    self.entity_type = 'User' if self.entity_type =~ /User/
    self.entity_type = 'Group' if self.entity_type =~ /Group/
  end
  
  ### basic info ###########################################################

  def full_name
    [name_prefix, first_name, middle_name, last_name, name_suffix].reject(&:blank?) * ' '
  end
  alias_method :name,  :full_name  

  def public?
    stranger?
  end
  
  def private?
    friend?
  end
  
  ### collections ########################################################## 

  belongs_to :wiki
  #belongs_to :photo
  #belongs_to :layout
  
  has_many   :locations,       :dependent => :destroy, :order=>"preferred desc"
  has_many   :email_addresses, :dependent => :destroy, :order=>"preferred desc"
  has_many   :im_addresses,    :dependent => :destroy, :order=>"preferred desc"
  has_many   :phone_numbers,   :dependent => :destroy, :order=>"preferred desc"
  has_many   :websites,        :dependent => :destroy, :order=>"preferred desc"
  has_many   :notes,           :class_name => 'Note', :dependent => :destroy, :order=>"preferred desc"

  # takes a huge params hash that includes sub hashes for dependent collections
  # and saves it all to the database.
  def save_from_params(profile_params)
    valid_params = ['first_name', 'middle_name', 'last_name', 'role', 'organization']
    collections = {
      'phone_numbers'   => Profile::PhoneNumber,   'locations' => Profile::Location,
      'email_addresses' => Profile::EmailAddress,  'websites'  => Profile::Website,
      'im_addresses'    => Profile::ImAddress,     'notes'     => Profile::Note
    }
    
    profile_params.stringify_keys!
    params = profile_params.limit_keys_to(valid_params)
    # save nil if value is an empty string:
    params.each do |key,value|
      params[key] = nil unless value.any?
    end
    
    # build objects from params
    collections.each do |collection_name, collection_class|
      params[collection_name] = profile_params[collection_name].collect do |key,value|
        # puts "%s.new ( %s )" % [collection_class, value.inspect]
        collection_class.new( value.merge('profile_id' => self.id.to_i) )
      end || [] rescue []
    end

    self.update_attributes( params )
    self.reload    
    self
  end

  def create_wiki
    return wiki unless wiki.nil?
    wiki = Wiki.create :profile => self
    save
    wiki
  end
    
end # class
