require 'tempfile'
require 'fileutils'

require File.join(File.dirname(__FILE__), 'abstract_unit')
require File.join(File.dirname(__FILE__), 'mock_file')
require 'flex_image/model'
require File.join(File.dirname(__FILE__), 'fixtures', 'image')

class FlexImageModelTest < Test::Unit::TestCase
  
  def setup
    Image.create!(:data => MockFile.new("#{File.dirname(__FILE__)}/fixtures/test.jpg"))
    @image = Image.find(:first)
  end
  
  def test_object_sanity
    assert_equal(@image, Image.find(:first))
    assert_size('800x600', @image)
  end
  
  def test_image_should_create_from_url
    i = Image.create!(:data => 'http://www.google.com/intl/en_ALL/images/logo.gif')
    assert(!i.new_record?, "Image was not properly created from url")
  end
  
  # Resize tests
  def test_resize_should_change_dimensions
    @image.resize! :size => '50x50'
    assert_size('50x38', @image)
  end
  
  def test_resize_should_crop
    @image.resize! :size => '50x50', :crop => true
    assert_size('50x50', @image)
  end
  
  def test_resize_should_not_upsample_image
    @image.resize! :size => '1000'
    assert_size('800x600', @image)
  end
  
  def test_resize_should_upsample_image
    @image.resize! :size => '1000', :upsample => true
    assert_size('1000x750', @image)
  end
  
  
  # Border tests
  def test_border_should_add_space
    old_color = @image.color_at('1x599')
    
    @image.border!
    assert_size('820x620', @image)
    
    assert_color([255,255,255], '0x620',  @image)
    assert_color([255,255,255], '10x610', @image)
    assert_color(old_color,     '11x609', @image)
  end
  
  def test_border_should_accept_size_and_color
    @image.border! :size => 50, :color => 'red'
    assert_size('900x700', @image)
    
    assert_color([255,0,0],     '0x0', @image)
    assert_color([255,0,0],     '49x49', @image)
    assert_color([255,255,255], '50x50', @image)
  end
  
  
  # Crop tests
  def test_crop_should_cut_out_a_white_piece
    @image.crop! :from => '10x10', :size => '20x25'
    assert_size('20x25', @image)
    
    x, y = @image.size.split('x').collect(&:to_i)
    x.times do |_x|
      y.times do |_y|
        assert_color([255,255,255], "#{_x}x#{_y}", @image)
      end
    end
  end
  
  
  # Overlay tests
  def test_overlay_should_stamp_image
    old_colors = {}
    %w( 25x25 49x37 50x50 200x150 ).each do |coords|
      old_colors[coords] = @image.color_at(coords)
    end
    
    @image.overlay! :file => "#{File.dirname(__FILE__)}/fixtures/test.jpg",
                    :size => '50',
                    :alignment => :top_left
    
    assert_size('800x600', @image)
    
    assert_not_color old_colors['25x25'],   '25x25',   @image
    assert_not_color old_colors['49x37'],   '49x37',   @image
    assert_color     old_colors['50x50'],   '50x50',   @image
    assert_color     old_colors['200x150'], '200x150', @image
  end
  
  def test_trim
    @image.border!
    assert_size('820x620', @image)
    
    @image.trim!
    assert_size('800x600', @image)
  end
  
  private
    def assert_size(expected, actual_obj)
      assert_equal(expected, actual_obj.size, "Image is the wrong size")
    end
    
    def assert_color(expected, coords, actual_obj)
      coords       = coords.split('x').collect(&:to_i)
      expected     = Magick::Pixel.new(*expected) unless expected.is_a?(Magick::Pixel)
      actual_color = actual_obj.color_at(coords)
      
      assert_equal(expected, actual_color, "Wrong color at (#{coords[0]},#{coords[1]})")
    end
    
    def assert_not_color(expected, coords, actual_obj)
      coords       = coords.split('x').collect(&:to_i)
      expected     = Magick::Pixel.new(*expected) unless expected.is_a?(Magick::Pixel)
      actual_color = actual_obj.color_at(coords)
      
      assert_not_equal(expected, actual_color, "Wrong color at (#{coords[0]},#{coords[1]})")
    end
end