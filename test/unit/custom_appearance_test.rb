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

    stylesheet_url = appearance.themed_stylesheet_url("screen.css", "ui_base")
    css_path = File.join("./public/stylesheets", stylesheet_url)

    assert File.exists?(css_path), "CustomAppearance#themed_stylesheet_url should generate a new file"

    css_text = File.read(css_path)

    assert css_text.length > 0

    # clear the cache
    CustomAppearance.clear_cached_css
    # should be deleted
    assert !File.exists?(css_path), "clearing css cache should delete cached files"

    # should regerate
    stylesheet_url = appearance.themed_stylesheet_url("screen.css", "ui_base")
    assert File.exists?(css_path), "CustomAppearance#themed_stylesheet_url should generate a new file"
  end

  def test_nonexisting_css
    assert_raise Errno::ENOENT do
      CustomAppearance.default.themed_stylesheet_url("does_not_exists.css", "ui_base");
    end
  end

  def test_generated_css_text
    appearance = custom_appearances(:default_appearance)

    # update appearance
    appearance.parameters["page_bg"] = "magenta"
    appearance.save!

    stylesheet_url = appearance.themed_stylesheet_url("screen.css", "ui_base")
    css_path = File.join("./public/stylesheets", stylesheet_url)
    css_text = File.read(css_path)
    assert css_text =~ /body\s*\{\s*.*background:\s*magenta/, "generated text must use updated background-color value"
  end

  def test_always_regenerate_options
    # first try always regenerate
    Conf.always_renegerate_themed_stylesheet = true
    appearance = custom_appearances(:default_appearance)

    # generate once
    stylesheet_url = appearance.themed_stylesheet_url("screen.css", "ui_base")
    css_path = File.join("./public/stylesheets", stylesheet_url)
    # remember the tyle
    mtime1 = File.mtime(css_path)

    # generate again
    sleep 1
    stylesheet_url = appearance.themed_stylesheet_url("screen.css", "ui_base")
    css_path = File.join("./public/stylesheets", stylesheet_url)
    # remember the time
    mtime2 = File.mtime(css_path)

    assert mtime2 > mtime1, "themed_stylesheet_url should aways regenerate the css file when Conf.always_renegerate_themed_stylesheet is true"

    # mimick the production mode
    Conf.always_renegerate_themed_stylesheet = false

    # generate once
    stylesheet_url = appearance.themed_stylesheet_url("screen.css", "ui_base")
    css_path = File.join("./public/stylesheets", stylesheet_url)
    # remember the time
    mtime1 = File.mtime(css_path)

    # generate again
    sleep 1
    stylesheet_url = appearance.themed_stylesheet_url("screen.css", "ui_base")
    css_path = File.join("./public/stylesheets", stylesheet_url)
    # remember the time
    mtime2 = File.mtime(css_path)

    assert mtime2 == mtime1, "themed_stylesheet_url should not always regenerate the css file when Conf.always_renegerate_themed_stylesheet is false"

    # now save appearance. this should force regeneration
    appearance.save!

    # generate again
    stylesheet_url = appearance.themed_stylesheet_url("screen.css", "ui_base")
    css_path = File.join("./public/stylesheets", stylesheet_url)
    # remember the tyle
    mtime3 = File.mtime(css_path)

    assert mtime3 > mtime2, "themed_stylesheet_url should aways regenerate the css file when custom appearance is updated"

    # restore the test default
    Conf.always_renegerate_themed_stylesheet = true
  end

  def test_available_parameters
    assert CustomAppearance.available_parameters.is_a?(Hash)
  end
end
