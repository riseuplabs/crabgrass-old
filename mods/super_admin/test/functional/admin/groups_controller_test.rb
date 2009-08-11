require File.dirname(__FILE__) + '/../../test_helper'

class Admin::GroupsControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships

  # none of the tests in here were written for the superadmin mod - they
  # all seemed to be a copy of the normal GroupsControllerTests.
  #  --azul

end
