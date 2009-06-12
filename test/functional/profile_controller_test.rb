require File.dirname(__FILE__) + '/../test_helper'
require 'profile_controller'

# Re-raise errors caught by the controller.
class ProfileController; def rescue_action(e) raise e end; end

class ProfileControllerTest < Test::Unit::TestCase
  fixtures :users, :sites

  def setup
    @controller = ProfileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

=begin  
  def test_show
    login_as :quentin
    user = users(:quentin)
    get :show, :id => user.profiles.public.id
    assert_response :success
#    assert_template 'show'
    get :show, :id => user.profiles.private.id
    assert_response :success
#    assert_template 'show'
    get :show, :id => users(:blue).profiles.public.id
    assert_response :redirect

  end
  
  def test_edit
    login_as :quentin
    user = users(:quentin)
    profile = {:may_request_contact => "1",
      :may_see_groups => "0",
      :may_see_contacts => "0",
      :may_pester => "1",
      :organization => "Test orga",
      :role => "test_role",
      :first_name => "first",
      :middle_name => "middle",
      :last_name => "last"}

    get :edit, :id => user.profiles.public.id
    assert_response :success
#    assert_template 'edit'
    %w(location email_address im_address phone_number note website crypt_key).each do |para|
      post "add_#{para}"
      assert_response :success

#We should really build a complete entry here.
#    "profile"=>{"email_addresses"=>{"5881736870"=>{"email_address"=>"", "email_type"=>"Home"}}, "may_request_contact"=>"1", "notes"=>{"5524426172"=>{"body"=>"blabla", "note_type"=>"About_Me"}, "7500138325"=>{"body"=>"soc cha in", "note_type"=>"Social_Change_Interests"}}, "may_see"=>"1", "websites"=>{"62708470"=>{"site_url"=>"", "site_title"=>""}}, "role"=>"the blue one", "phone_numbers"=>{"6924990782"=>{"phone_number_type"=>"Home", "phone_number"=>""}}, "may_see_contacts"=>"0", "crypt_keys"=>{"2324808745"=>{"key"=>""}}, "im_addresses"=>{"2074622948"=>{"im_type"=>"Jabber", "im_address"=>""}}, "last_name"=>"name", "locations"=>{"9731222405"=>{"country_name"=>"Germany", "city"=>"Berlin", "postal_code"=>"", "street"=>"Alexanderplatz", "location_type"=>"Home", "state"=>""}, "2754212355"=>{"country_name"=>"", "city"=>"", "postal_code"=>"", "street"=>"", "location_type"=>"Home", "state"=>""}}, "organization"=>"blue orga", "may_see_groups"=>"0", "may_pester"=>"1", "middle_name"=>"blue", "first_name"=>"my"}, "action"=>"edit", "authenticity_token"=>"c779e440882b3e037a91f5b0d8ad6bc7fc75aa78", "id"=>"public", "save"=>"Save Changes", "controller"=>"profile"

    end
    post :edit, :id => "public",
      :save => "Save Changes",
      :profile => profile
    assert_response :redirect
  end

=end

end
