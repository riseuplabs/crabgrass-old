class GroupSetting < ActiveRecord::Base
  belongs_to :group
 
  serialize :template_data
  serialize :allowed_tools
  
end
