module CustomAppearanceExtension
  module Parameters
    # how tall can the masthead image be
    MASTHEAD_IMAGE_MAX_HEIGHT = 80

    def self.included(base)
      base.extend ClassMethods
    end

    def masthead_asset_uploaded_data
      masthead_asset.url if masthead_asset
    end

    def masthead_asset_uploaded_data=(data)
      return if data == ""
      begin
        asset = Asset.make!({:uploaded_data => data})
        if !asset.is_image
          # raise ActiveRecord::RecordInvalid.new "not an image"
          self.errors.add_to_base("Uploaded data is not an image. Try png or jpeg files."[:not_an_image_error])
        elsif asset.height > MASTHEAD_IMAGE_MAX_HEIGHT
          # raise ActiveRecord::RecordInvalid.new("Too tall")
          self.errors.add_to_base("Uploaded image is too tall (80 pixels is the max height)"[:too_tall_image_error])
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

    def masthead_background_parameter
      background = self.parameters['masthead_background'] || CustomAppearance.available_parameters['masthead_background'] || 'white'
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

      self.parameters['masthead_background'] = value
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