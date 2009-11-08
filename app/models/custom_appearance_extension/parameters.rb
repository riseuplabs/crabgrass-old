module CustomAppearanceExtension
  module Parameters
    # how tall can the masthead image be
    MASTHEAD_IMAGE_MAX_HEIGHT = 80
    # [W, H]
    FAVICON_DIMENSIONS = [[16, 16], [32, 32]]

    def self.included(base)
      base.extend ClassMethods
    end

    def delete_bad_parameters
      parameters.delete_if {|k, v| v.nil?}
    end

    def masthead_asset_uploaded_data
      masthead_asset.url if masthead_asset
    end

    def masthead_asset_uploaded_data=(data)
      return if data == ""
      begin
        asset = Asset.make!({:uploaded_data => data})
        if !asset.is_image
          self.errors.add_to_base("Uploaded data is not an image. Try png or jpeg files."[:not_an_image_error])
        elsif !asset.height
          self.errors.add_to_base("Can't detect image height. Either the image is corrupted or the server has experienced an error"[:cant_detect_image_height_error])
        elsif asset.height > MASTHEAD_IMAGE_MAX_HEIGHT
          self.errors.add_to_base("Uploaded image is too tall ({count} pixels is the max height)"[:too_tall_image_error, {:count => MASTHEAD_IMAGE_MAX_HEIGHT}])
        else
          # all good
          # delete the old masthead asset
          self.masthead_asset.destroy if self.masthead_asset
          self.masthead_asset = asset
        end
      rescue ActiveRecord::RecordInvalid => exc
        self.errors.add_to_base(exc.message)
      end

      unless self.errors.empty?
        raise ActiveRecord::RecordInvalid.new(self)
      end
    end

    def favicon_uploaded_data
      favicon.url if favicon
    end

    def favicon_uploaded_data=(data)
      return if data == ""
      begin
        asset = Asset.make!({:uploaded_data => data})
        if !asset.is_image
          self.errors.add_to_base("Uploaded data is not an favicon image format. Try png, gif files."[:not_a_favicon_image_error])
        elsif !asset.height or !asset.width
          self.errors.add_to_base("Can't detect image height. Either the image is corrupted or the server has experienced an error"[:cant_detect_image_height_error])
        elsif !FAVICON_DIMENSIONS.include?([asset.width, asset.height])
          self.errors.add_to_base("Uploaded favicon image is wrong dimensions. It must be either 16x16 or 32x32"[:favicon_image_bad_dimensions_error])
        else
          # all good
          # delete the old masthead asset
          self.favicon.destroy if self.favicon
          self.favicon = asset
        end
      rescue ActiveRecord::RecordInvalid => exc
        self.errors.add_to_base(exc.message)
      end

      unless self.errors.empty?
        raise ActiveRecord::RecordInvalid.new(self)
      end
    end

    def masthead_background_parameter
      background = self.parameters['masthead_background'] || CustomAppearance.available_parameters['masthead_background']
      background = 'white' if !background || background.empty?
      background.gsub /^#/, ""
    end

    def masthead_background_parameter=(value)
      # hopefully we won't run into color names that match this criteria
      if value.size == 3 or value.size == 6
        if value.upcase =~ /^([A-F0-9])+$/
          # add the color #
          value = "#" + value
        end
      end

      self.parameters['masthead_background'] = value.any? ? value : 'white'
    end

    def masthead_enabled
      display = self.parameters['masthead_display'] || CustomAppearance.available_parameters['masthead_display']
      if display =~ /none/ or !display
        # display is set to none or is not set at all
        false
      else
        true
      end
    end

    def masthead_enabled=(value)
      display = 'none'
      if value =~ /block|inline|table|none/
        # setting the direct css display property
        display = value
      elsif value == "0"
        display = 'none'
      else
        # is value something positive?
        display = (value ? 'block' : 'none')
      end
      self.parameters['masthead_display'] = display
    end

    protected

    module ClassMethods
      def available_parameters
        parameters = {}
        # parse the constants.sass file and return the hash
        constants_lines = File.readlines(File.join(CustomAppearance::SASS_ROOT, CustomAppearance::CONSTANTS_FILENAME))
        constants_lines.reject! {|l| l !~ /^\s*!\w+/ }
        constants_lines.each do |l|
          k, v = l.chomp.split(/\s*=\s*/)
          k[/^!/] = ""
          parameters[k] = v
        end
        parameters
      end
    end
  end
end
