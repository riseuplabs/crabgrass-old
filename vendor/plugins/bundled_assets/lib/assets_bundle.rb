class AssetsBundle
            
  class << self
    attr_accessor :options
  end
  
  self.options = { :compress => [:css, :js],
                   :css_keep_comments => false,
                   :paths => { :css   => '/public/stylesheets/',
                               :js    => '/public/javascripts/' }, 
                   :jsmin => "ruby #{File.dirname(__FILE__)}/jsmin.rb" }
  
  def initialize(names, ext, options = {})    
    @names, @ext = names, ext
    self.options = options
  end
  
  def options=(options)
    @options = self.class.options.merge(options)
    @options[:compress] ||= []
    @options[:compress] = [@options[:compress]] if !@options[:compress].instance_of?(Array)    
  end
  
  def content
    if @content.nil?
      grab_content
      compress if compress?
    end
    @content
  end
  
  def content_type
    case @ext
    when 'css' then 'text/css'
    when 'js'  then 'text/javascript'
    end
  end
  
  def compress?
    @options[:compress].include? @ext.to_sym
  end
  
  def jsmin
    @options[:jsmin]
  end
  
  def css_keep_comments?
    @options[:css_keep_comments]
  end
  
  def path(type)
    @options[:paths][type.to_sym]
  end
  
  def grab_content
    @content = filenames.inject([]) { |c, name| c << open(name) { |f| f.read } }.join("\n")
  end
  
  def filenames
    @names.split(/,/).inject([]) do |res, name|
      if    f = file(name) then res << f
      elsif d = dir(name)  then res += glob_dir(d)
      else res end
    end
  end
  
  def file(name)    
    return name if File.file?(name = basedir + name + '.' + @ext)
  end
  
  def dir(name)
    return name if File.directory?(name = basedir + name)
  end
  
  def glob_dir(name)
    Dir.glob(File.join(name, '**', "*.#{@ext}")).sort
  end
  
  def basedir(type = nil)
    if ENV['RAILS_ENV'] == 'test'
      File.dirname(__FILE__) + '/../test/'
    else         
      RAILS_ROOT + path(type || @ext)
    end
  end  
  
  def compress
    send ('compress_' + @ext).to_sym
  end
  
  def compress_js
    require 'tempfile'
    tmp = Tempfile.new('bundled_assets_js')    
    tmp << @content
    tmp.close
    @content = `#{@options[:jsmin]} <#{tmp.path} \n`
    tmp.unlink
  end

  def compress_css                       # from http://synthesis.sbecker.net/pages/asset_packager    
    @content.gsub!(/\s+/, " ")           # collapse space
                                         # remove comments !!! caution if using css hacks !!! use option :css_keep_comments => true
    @content.gsub!(/\/\*(.*?)\*\/ /, "") unless css_keep_comments?
    @content.gsub!(/\} /, "}\n")         # add line breaks
    @content.gsub!(/\n$/, "")            # remove last break
    @content.gsub!(/ \{ /, " {")         # trim inside brackets
    @content.gsub!(/; \}/, "}")          # trim inside brackets
  end
end
