require "#{File.dirname(__FILE__)}/../test_helper"

class CustomAppearancesTest < ActionController::IntegrationTest
  fixtures :sites, :custom_appearances, :groups, :users

  def test_site_custom_appearance_cache
    CustomAppearance.clear_cached_css
    host! 'localhost'
    get '/'

    # make sure the site has the custom appearance we want
    assert_equal @controller.current_site.custom_appearance.id, custom_appearances(:localhost_appearance).id

    assert_response :success
    assert_select "link[rel='stylesheet'][href=?]", /.*as_needed.*account.css.*/ do |links|
      assert_equal 1, links.size
      assert_equal "/stylesheets/as_needed/account.css", links.first.attributes["href"]
    end

    assert !@controller.current_site.custom_appearance.has_cached_css?('as_needed/account.css')

    # get the stylesheet
    get '/stylesheets/as_needed/account.css'
    assert_response :success
    assert @response.body.size > 0

    # should be cached
    assert @controller.current_site.custom_appearance.has_cached_css?('as_needed/account.css')

    get '/'
    assert_select "link[rel='stylesheet'][href=?]", /.*as_needed.*account.css.*/ do |links|
      assert_equal 1, links.size
      assert links.first.attributes["href"] =~ %r{/stylesheets/themes/\d+/\d+/as_needed/account.css}
    end
  end

  def test_default_appearance_cache
    CustomAppearance.clear_cached_css
    host! 'test.host'
    get '/'

    # make sure the site has the custom appearance we want
    assert_nil @controller.current_site.custom_appearance

    assert_response :success
    assert_select "link[rel='stylesheet'][href=?]", /.*as_needed.*account.css.*/ do |links|
      assert_equal 1, links.size
      assert_equal "/stylesheets/as_needed/account.css", links.first.attributes["href"]
    end

    assert !CustomAppearance.default.has_cached_css?('as_needed/account.css')

    # get the stylesheet
    get '/stylesheets/as_needed/account.css'
    assert_response :success
    assert @response.body.size > 0

    # should be cached
    assert CustomAppearance.default.has_cached_css?('as_needed/account.css')

    get '/'
    assert_select "link[rel='stylesheet'][href=?]", /.*as_needed.*account.css.*/ do |links|
      assert_equal 1, links.size
      assert links.first.attributes["href"] =~ %r{/stylesheets/themes/\d+/\d+/as_needed/account.css}
    end
  end
end
