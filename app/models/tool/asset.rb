require 'asset'
class Tool::Asset < Page
  controller 'asset'
  model ::Asset
  icon 'package.png'
  class_display_name 'file'
  class_description 'an uploaded file'
  class_group 'asset'

  after_save :update_access
  def update_access
    asset.update_access if asset
  end

  def asset
    self.data
  end

  def asset=(a)
    self.data = a
  end
end
