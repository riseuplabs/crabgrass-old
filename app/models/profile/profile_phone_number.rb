=begin

=end

class ProfilePhoneNumber < ActiveRecord::Base

  set_table_name 'phone_numbers'

  validates_presence_of :phone_number_type
  validates_presence_of :phone_number

  belongs_to :profile, :class_name => 'Profile', :foreign_key => 'profile_id'

  after_save {|record| record.profile.save if record.profile}
  after_destroy {|record| record.profile.save if record.profile}

  def self.options
    [:Home,:Fax,:Mobile,:Pager,:Work, :Other].to_localized_select
  end

  def icon
    case self.phone_number_type
      when 'Home'   : 'house'
      when 'Fax'    : 'fax'
      when 'Mobile' : 'mobile'
      when 'Pager'  : 'mobile'
      else 'phone'
    end
  end

end
