require File.dirname(__FILE__) + '/../test_helper'

class CustomAppearaceTest < ActiveSupport::TestCase
  fixtures :custom_appearances

  def setup
    # delete cached css
    CustomAppearance.clear_cached_css
  end

  def test_generate_css_and_clear_cache
    appearance = custom_appearances(:default_appearance)

    # update appearance
    appearance.parameters["box1_bg_color"] = "green"
    appearance.save!

    stylesheet_url = appearance.themed_stylesheet_url("screen.css")
    css_path = File.join("./public/stylesheets", stylesheet_url)

    assert File.exists?(css_path), "CustomAppearance#themed_stylesheet_url should generate a new file"

    css_text = File.read(css_path)

    assert css_text.length > 0

    # clear the cache
    CustomAppearance.clear_cached_css
    # should be deleted
    assert !File.exists?(css_path), "clearing css cache should delete cached files"

    # should regerate
    stylesheet_url = appearance.themed_stylesheet_url("screen.css")
    assert File.exists?(css_path), "CustomAppearance#themed_stylesheet_url should generate a new file"
  end

  def test_nonexisting_css
    assert_raise Errno::ENOENT do
      CustomAppearance.default.themed_stylesheet_url("does_not_exists.css");
    end
  end

  def test_generated_css_text
    appearance = custom_appearances(:default_appearance)

    # update appearance
    appearance.parameters["left_column_bg_color"] = "magenta"
    appearance.save!

    stylesheet_url = appearance.themed_stylesheet_url("screen.css")
    css_path = File.join("./public/stylesheets", stylesheet_url)
    css_text = File.read(css_path)
    assert css_text =~ /leftmenu\s*\{\s*background-color:\s*magenta/, "generated text must use updated background-color value"
  end

  def test_available_parameters
    assert CustomAppearance.available_parameters.is_a?(Hash)
  end
end
