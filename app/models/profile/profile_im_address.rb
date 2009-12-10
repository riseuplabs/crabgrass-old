=begin

=end

class ProfileImAddress < ActiveRecord::Base

  set_table_name 'im_addresses'

  validates_presence_of :im_type
  validates_presence_of :im_address

  belongs_to :profile

  after_save {|record| record.profile.save if record.profile}
  after_destroy {|record| record.profile.save if record.profile}

  def self.options
    ['Jabber', 'IRC', 'Silc', 'Gizmo', 'AIM',
    'Google Talk', 'MSN', 'Skype', 'Yahoo', 'Other'].to_localized_select
  end

  def icon
    'page_discussion'
  end
end
