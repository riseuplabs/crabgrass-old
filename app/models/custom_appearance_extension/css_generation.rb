module CustomAppearanceExtension
  module CssGeneration
    def self.included(base)
      base.extend ClassMethods
    end

    protected

    # reads the sass file file for +css_url+ and generates themed
    # css (by overriding sass constants with +parameters+) saving it into
    # +themed_css_path+ file
    def generate_css_file_for_url(themed_css_path, css_url)
      # here's the steps:
      # 1. load all necessary sass code into a string
      # 2. render Sass code string into a css string
      # 3. save the rendered css as themed_css_path file

      # make the sass string
      sass_text = generate_overloaded_sass_string(css_url)

      # render css from or sass text
      engine = Sass::Engine.new(sass_text, :load_paths => CustomAppearance::SASS_LOAD_PATHS)
      css_text = engine.render

      # create the directory
      themed_css_dir = File.dirname(themed_css_path)
      FileUtils.mkpath(themed_css_dir)
      # write the css
      File.open(themed_css_path, "w+") {|f| f.write css_text}

      # return the text
      css_text
    end

    def generate_overloaded_sass_string(css_url)
      # steps:
      #   a. append constants.sass
      #   b. append sass_override_code, which will change the values of some constants
      #   c. append the sass file for +css_url+ (like sass/as_needed/wiki.sass for as_needed/wiki.css)

      sass_text = ""

      # read the constants
      constants_sass_path = File.join(CustomAppearance::SASS_ROOT, CustomAppearance::CONSTANTS_FILENAME)
      sass_text << File.read(constants_sass_path)

      # load the custom appearance constants from +parameters+
      sass_text << "\n" << sass_override_code

      # load the requested file
      source_sass_path = source_sass_path(css_url)
      sass_text << File.read(source_sass_path)
    end

    def sass_override_code
      text = ""
      parameters.each {|k, v| text << %Q[!#{k} = "#{v}"\n]}
      text << "\n"
    end


    module ClassMethods
      def clear_cached_css
        path = File.join(CustomAppearance::STYLESHEETS_ROOT, 'themes')
        pattern = path + "/**"
        FileUtils.rm_rf(Dir.glob(pattern))
      end
    end
  end
end