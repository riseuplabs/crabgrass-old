=begin

=end

module Profile

class PhoneNumber < ActiveRecord::Base
  validates_presence_of :phone_number_type
  validates_presence_of :phone_number

  belongs_to :profile

  after_save {|record| record.profile.save if record.profile}
  after_destroy {|record| record.profile.save if record.profile}
  
  def self.options
    %w[Home Fax Mobile Other Pager Work].to_localized_select
  end
  
end

end
