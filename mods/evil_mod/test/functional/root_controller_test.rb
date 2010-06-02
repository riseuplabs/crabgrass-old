require File.dirname(__FILE__) + '/../test_helper'

class RootControllerTest < ActionController::TestCase
  fixtures :groups, :users, :memberships, :sites

  include UrlHelper


  def test_google_analytics_script
    login_as :red

    site = sites(:test)
    site.evil = {'google_analytics' => {
        'site_id' => 'AB-1234567-01',
        'https' => true,
        'enabled' => true}
    }
    site.save

    with_site :test do
      get :index
      assert_response :success
      assert_select 'div.footer' do
        assert_select 'script[src="https://www.google-analytics.com/urchin.js"]'
        string = <<EOS
_uacct = "AB-1234567-01";
urchinTracker();
EOS
        assert_select 'script:last-of-type', /.*AB-1234567-01.*/
      end

    end

  end
end
