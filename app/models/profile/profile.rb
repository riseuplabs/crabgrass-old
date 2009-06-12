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

  create_table "profiles", :force => true do |t|
    t.integer  "entity_id",              :limit => 11
    t.string   "entity_type"
    t.boolean  "stranger"
    t.boolean  "peer"
    t.boolean  "friend"
    t.boolean  "foe"
    t.string   "name_prefix"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "name_suffix"
    t.string   "nickname"
    t.string   "role"
    t.string   "organization"
    t.string   "place"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "birthday",               :limit => 8
    t.boolean  "fof"
    t.text     "summary"
    t.text     "summary_html"
    t.integer  "wiki_id",                :limit => 11
    t.integer  "photo_id",               :limit => 11
    t.integer  "layout_id",              :limit => 11
    t.boolean  "may_see"                 :default => true
    t.boolean  "may_see_committees"
    t.boolean  "may_see_networks"
    t.boolean  "may_see_members"
    t.boolean  "may_request_membership"
    t.integer  "membership_policy",      :limit => 11
    t.boolean  "may_see_groups"
    t.boolean  "may_see_contacts"
    t.boolean  "may_request_contact"     :default => true
    t.boolean  "may_pester"              :default => true
    t.boolean  "may_burden"
    t.boolean  "may_spy"
    t.string   "language",               :limit => 5
  end

Applies to both groups and users: may_see, may_see_groups

Applies to users only: may_see_contacts, may_request_contact, may_pester

Applies to groups only: may_see_committees, may_see_networks, may_see_members,
  may_request_membership, membership_policy

Currently unused: membership_policy, may_burden, may_spy, language.

=end

class Profile < ActiveRecord::Base

  belongs_to :language

  ##
  ## RELATIONSHIPS TO USERS AND GROUPS
  ## 
  
  belongs_to :entity, :polymorphic => true
  def user; entity; end
  def group; entity; end
    
  before_create :fix_polymorphic_single_table_inheritance
  def fix_polymorphic_single_table_inheritance
    self.entity_type = 'User' if self.entity_type =~ /User/
    self.entity_type = 'Group' if self.entity_type =~ /Group/
  end
  
  ##
  ## BASIC ATTRIBUTES
  ##

  format_attribute :summary

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
  
  def type
    return 'public' if stranger?
    return 'private' if friend?
    return 'unknown'
  end

  ##
  ## ASSOCIATED ATTRIBUTES
  ##

  belongs_to :wiki, :dependent => :destroy
  belongs_to :wall,
   :class_name => 'Discussion',
   :foreign_key => 'discussion_id',
   :dependent => :destroy

  belongs_to :photo, :class_name => "Asset", :dependent => :destroy
  belongs_to :video, :class_name => "ExternalVideo", :dependent => :destroy
 
  has_many :locations,
    :class_name => '::ProfileLocation',
    :dependent => :destroy, :order => "preferred desc"

  has_many :email_addresses,
    :class_name => '::ProfileEmailAddress',
    :dependent => :destroy, :order => "preferred desc"

  has_many :im_addresses,
    :class_name => '::ProfileImAddress',
    :dependent => :destroy, :order => "preferred desc"

  has_many :phone_numbers,
    :class_name => '::ProfilePhoneNumber',
    :dependent => :destroy, :order => "preferred desc"

  has_many :websites,
    :class_name => '::ProfileWebsite',
    :dependent => :destroy, :order => "preferred desc"

  has_many :notes,
    :class_name => '::ProfileNote',
    :dependent => :destroy, :order => "preferred desc"

  has_many :crypt_keys,
    :class_name => '::ProfileCryptKey',
    :dependent => :destroy, :order => "preferred desc"

  # takes a huge params hash that includes sub hashes for dependent collections
  # and saves it all to the database.
  def save_from_params(profile_params)

    valid_params = ["first_name", "middle_name", "last_name", "role",
      "organization", "place", "may_see", "may_see_committees", "may_see_networks",
      "may_see_members", "may_request_membership", "membership_policy",
      "may_see_groups", "may_see_contacts", "may_request_contact", "may_pester",
<<<<<<< HEAD:app/models/profile/profile.rb
      "may_burden", "may_spy", "peer", "city", "country"]
=======
      "may_burden", "may_spy", "peer", "photo", "video", "summary"]
>>>>>>> master:app/models/profile/profile.rb

    collections = {
      'phone_numbers'   => ::ProfilePhoneNumber,   'locations' => ::ProfileLocation,
      'email_addresses' => ::ProfileEmailAddress,  'websites'  => ::ProfileWebsite,
      'im_addresses'    => ::ProfileImAddress,     'notes'     => ::ProfileNote,
      'crypt_keys'      => ::ProfileCryptKey
    }
    
    profile_params.stringify_keys!
    params = profile_params.allow(valid_params)
    params['summary_html'] = nil if params['summary'] == ""

    # save nil if value is an empty string:
    params.each do |key,value|
      params[key] = nil unless value.any?
    end
    
    # build objects from params
    collections.each do |collection_name, collection_class|
      params[collection_name] = profile_params[collection_name].collect do |key,value|
        # puts "%s.new ( %s )" % [collection_class, value.inspect]
        collection_class.create( value.merge('profile_id' => self.id.to_i) )
      end || [] rescue []
    end
    
    params['photo'] = Asset.build(params.delete('photo')) if params['photo']
    params['video'] = ExternalVideo.new(params.delete('video')) if params['video']

    self.update_attributes( params )
    self.reload
    self
  end
  
  def cover
    self.photo || self.video
  end

  # DEPRECATED
  def create_wiki(opts = {})
    return wiki unless wiki.nil?
    opts[:profile] = self
    wiki = Wiki.create opts
    save
    wiki
  end

   def ensure_wall
     unless self.wall
       self.wall = Discussion.create
       self.save!
     end
     self.wall
   end
   
   # UNICEF wants the "location" field in the general information section to
   # be split into "city" and "country". This is an attempt to archieve this
   # while keeping consistency with old data.
   # Old data will be displayed as the city now.
   
   def place=(val)
     if val.kind_of?(String)
       write_attribute(:place, val)
     elsif val.kind_of?(Hash)
       write_attribute(:place, val.to_yaml)
     end
   end
   
   def place
     val = read_attribute(:place)
     if val =~ /^--- /
       begin
         YAML.load(val)
       rescue => exc
         val
       end
     elsif val.empty?
       {}
     else
       val
     end
   end
   
   def city
     val = place
     if val.kind_of?(String)
       val
     else
       val[:city]
     end
   end
   
   def city=(val)
     place = self.place
     if place.kind_of?(Hash)
       self.place = place.merge(:city => val)
     else
       self.place = { :city => val}
     end
   end
   
   def country
     val = place
     if val.kind_of?(String)
       ''
     else
       val[:country]
     end
   end
   
   def country=(val)
     place = self.place
     if place.kind_of?(Hash)
       self.place = place.merge(:country => val)
     else
       self.place = { :country => val}
     end
   end

end # class
