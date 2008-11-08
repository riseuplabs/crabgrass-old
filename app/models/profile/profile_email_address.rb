=begin

=end

class ProfileEmailAddress < ActiveRecord::Base

  set_table_name 'email_addresses'

  @@icons=Hash.new('page_message').merge({ 
  })

  validates_presence_of :email_type
  validates_presence_of :email_address
  #validates_as_email :email_address
  
    belongs_to :profile, :class_name => 'Profile', :foreign_key => 'profile_id'

  after_save {|record| record.profile.save if record.profile}
  after_destroy {|record| record.profile.save if record.profile}
  
  def self.options
    [:Home, :Work, :School, :Personal, :Group, :Other].to_localized_select
  end

  def icon
    @@icons[email_type]
  end
end
