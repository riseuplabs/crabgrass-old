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

    assert !appearance.has_cached_css?("screen.css")
    css_text = CustomAppearance.generate_css("screen.css", appearance)
    assert css_text.length > 0
    # should have cached css
    assert appearance.has_cached_css?("screen.css")
    css_full_path = appearance.cached_css_full_path("screen.css")
    # the file should exist and be the same as the text
    assert File.exists?(css_full_path)
    assert_equal css_text, File.read(css_full_path), "generated and cached css should be the same"

    # clear the cache
    CustomAppearance.clear_cached_css
    assert !File.exists?(css_full_path), "clearing css cache should delete cached files"
  end

  def test_nonexisting_css
    assert_raise Errno::ENOENT do
      CustomAppearance.generate_css("does_not_exists.css");
    end
  end

  def test_generated_css_text
    appearance = custom_appearances(:default_appearance)

    # update appearance
    appearance.parameters["left_column_bg_color"] = "magenta"
    appearance.save!

    css_text = CustomAppearance.generate_css("screen.css", appearance)
    assert css_text =~ /leftmenu\s*\{\s*background-color:\s*magenta/, "generated text must use updated background-color value"
  end
end
