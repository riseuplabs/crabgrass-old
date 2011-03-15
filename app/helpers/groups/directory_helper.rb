module Groups::DirectoryHelper

  def directory_groups_type(type)
    I18n.t(type)
  end

  def kml_description(group)
    'this is the description for group '+group.name+' it can contain <b>tags</b>'
  end

end
