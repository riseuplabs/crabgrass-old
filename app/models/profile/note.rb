=begin

=end
class Profile::Note < ActiveRecord::Base
  validates_presence_of :type
  validates_presence_of :body

  set_table_name 'profile_notes'

  belongs_to :profile, :class_name => 'Profile::Profile'

  after_save {|record| record.profile.save if record.profile}
  after_destroy {|record| record.profile.save if record.profile}
  
  def self.options
    ['About Me', 'Social Change Interests', 'Personal Interests', 'Work Life'].to_localized_select
  end
  
end
