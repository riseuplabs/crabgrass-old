#
# This is a placeholder until PersonController is converted into
# using RESTful routes.
#
class People::PeopleController < People::BaseController

  def index
    redirect_to people_directory_index_url
  end


  protected

end

