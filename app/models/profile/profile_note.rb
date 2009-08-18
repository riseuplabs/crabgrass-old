=begin

=end
class ProfileNote < ActiveRecord::Base
  validates_presence_of :body

  set_table_name 'profile_notes'

  belongs_to :profile

  after_save {|record| record.profile.save if record.profile}
  after_destroy {|record| record.profile.save if record.profile}

  def self.options
    [:About_Me, :Social_Change_Interests, :Personal_Interests, :Work_Life].to_localized_select
  end

  def icon
    'info'
  end

end
