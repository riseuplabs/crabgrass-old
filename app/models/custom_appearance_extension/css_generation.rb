module CustomAppearanceExtension
  module CssGeneration
    def self.included(base)
      base.extend ClassMethods
    end

    protected

    # reads the sass or scss file for +css_url+ and generates themed
    # css (by overriding sass constants with +parameters+) saving it into
    # +themed_css_path+ file
    def generate_css_file_for_url(themed_css_path, css_url, css_prefix_path=nil)
      # here's the steps:
      # 1. load all necessary sass or scss code into a string
      # 2. render the code string into a css string
      # 3. save the rendered css as themed_css_path file

      #alternative_constants_path

      # make the style string
      style_text = generate_overloaded_style_string(css_url, css_prefix_path)

      # render css from or sass or scss text
      options = Compass.configuration.to_sass_engine_options
      options[:syntax] = :scss
      options[:load_paths] = options[:load_paths] | CustomAppearance::SASS_LOAD_PATHS
      engine = Sass::Engine.new(style_text, options)
      css_text = engine.render

      # create the directory
      themed_css_dir = File.dirname(themed_css_path)
      FileUtils.mkpath(themed_css_dir)
      # write the css
      File.open(themed_css_path, "w+") {|f| f.write css_text}

      # return the text
      css_text
    end

    def generate_overloaded_style_string(css_url, css_prefix_path=nil)
      # steps:
      #   a. append constants file
      #   b. append style_override_code, which will change the values of some constants
      #   c. append the style file for +css_url+ (like sass/as_needed/wiki.scss for as_needed/wiki.css)

      style_text = ""

      # read the constants
      if css_prefix_path
        constants_path = File.join(RAILS_ROOT, CustomAppearance::SASS_ROOT, css_prefix_path, CustomAppearance::CONSTANTS_FILENAME)
      else
        constants_path = File.join(RAILS_ROOT, CustomAppearance::SASS_ROOT, CustomAppearance::CONSTANTS_FILENAME)
      end

      style_text << File.read(constants_path)

      # load the custom appearance constants from +parameters+
      style_text << "\n" << style_override_code

      # load the requested file
      source_path = source_style_path(css_url, css_prefix_path)
      style_text << File.read(source_path)
    end

    def style_override_code
      text = ""
      parameters.each {|k, v| text << %Q[$#{k}: "#{v}";\n]}
      text << "\n"
    end


    module ClassMethods
      def clear_cached_css
        %w{themes, compiled}.each do |dir|
          path = File.join(CustomAppearance::STYLESHEETS_ROOT, dir)
          pattern = path + "/**"
          FileUtils.rm_rf(Dir.glob(pattern))
        end
      end
    end
  end
end
