require "#{File.dirname(__FILE__)}/../test_helper"

class CustomAppearancesTest < ActionController::IntegrationTest
  fixtures :sites, :custom_appearances, :groups, :users

  def test_custom_appearance_cache
    CustomAppearance.clear_cached_css
    host! 'test.host'
    get '/'

    # make sure the site has the custom appearance we want
    stylesheet_url = ""
    assert_nil @controller.current_site.custom_appearance
    assert_response :success
    assert_select "link[rel='stylesheet'][href=?]", /.*as_needed.*account.css.*/ do |links|
      assert_equal 1, links.size
      stylesheet_url = links.first.attributes["href"]
      assert links.first.attributes["href"] =~ %r{/stylesheets/themes/\d+/\d+/as_needed/account.css\?\d+}
    end

    # get the stylesheet
    css_text = File.read("./public" + stylesheet_url.gsub(/\?\d+$/, ""))

    assert css_text.size > 0
  end
end
