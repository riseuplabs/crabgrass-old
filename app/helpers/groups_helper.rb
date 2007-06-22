module GroupsHelper

  include PageFinders
  
  def committee?
    @group.instance_of? Committee
  end
  
  def network?
    @group.instance_of? Network
  end
  
end
