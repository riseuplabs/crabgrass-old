class Networks::DirectoryController < Groups::DirectoryController

  protected
  
  def context
    network_context
  end

  def set_group_type
    @group_type = :network
  end

end
