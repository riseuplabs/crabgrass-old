module CustomAppearanceExtension
  module CssPaths
    def self.included(base)
      base.extend ClassMethods
    end

    STYLESHEETS_ROOT = './public/stylesheets'
    SASS_ROOT = './app/stylesheets'
    CONSTANTS_FILENAME = "constants.sass"
    SASS_LOAD_PATHS = ['.', File.join(RAILS_ROOT, SASS_ROOT)]

    protected

    # :cal-seq:
    #   'as_needed/wiki.css' => './public/stylesheets/themes/2/2009081233/as_needed/wiki.css'
    def themed_css_path(css_url, css_prefix_path=nil)
      File.join(RAILS_ROOT, STYLESHEETS_ROOT, themed_css_url(css_url, css_prefix_path))
    end

    # :cal-seq:
    #   'as_needed/wiki.css' => 'themes/2/2009081233/as_needed/wiki.css'
    def themed_css_url(css_url, css_prefix_path=nil)
      if css_prefix_path
        File.join("compiled", css_prefix_path, theme_prefix, css_url)
      else
        File.join(theme_prefix, css_url)
      end
    end

    # :cal-seq:
    #   'as_needed/wiki.css' => RAILS_ROOT + './public/stylesheets/sass/as_needed/wiki.sass'
    def source_sass_path(css_url, css_prefix_path=nil)
      if css_prefix_path
        File.join(RAILS_ROOT, SASS_ROOT, css_prefix_path, css_url).gsub(/.css$/, ".sass")
      else
        File.join(RAILS_ROOT, SASS_ROOT, css_url).gsub(/.css$/, ".sass")
      end
    end

    # appends .css suffix if missing
    # 'as_needed/wiki.css' => 'as_needed/wiki.css'
    # 'as_needed/wiki' => 'as_needed/wiki.css'
    def ensure_dot_css(css_url)
      css_url =~ /\.css$/ ? css_url : css_url + ".css"
    end

    # returns 'themes/self.id/self.timestamp' or 'themes/default' is self is not saved
    def theme_prefix
      if self.new_record?
        "themes/default"
      else
        "themes/#{self.id}/#{self.updated_at.to_i}"
      end
    end

    module ClassMethods
    end
  end
end
