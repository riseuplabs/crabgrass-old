#
# servers a rendered png of some latex code
#

# requires:
# apt-get install graphicsmagick tetex-bin gs-gpl
# gem install open4
#

require 'digest/md5'
require 'zlib'
require 'base64'

class LatexController < ApplicationController

  skip_before_filter :login_required  
  #caches_page :show
  
  def show
    begin
      equation = params[:path].join("\n")
      equation = decode_and_expand_url_data(equation)
      # return render :text => "<pre>%s</pre>" % equation
      if equation !~ /^\\begin/
        equation = "$\n#{equation}\n$"
      end
      latex = @@latex_head + equation + @@latex_tail
      blob = get_image_from_latex(latex)
      cache_page :controller=> 'latex', :action=>'show', :path => params[:path]
      send_data(blob, :type => 'image/png', :disposition => 'inline')
    rescue Exception => exc
      expire_page :controller=> 'latex', :action=>'show', :path => params[:path]
      render :text => "<pre>%s</pre>" % exc.to_s
    end
  end
  
  private
  
  def decode_and_expand_url_data(string)
    Zlib::Inflate.inflate( Base64.decode64(string) )
  end

  # this uses the LatexRenderer plugin from mephisto.
  # i have just copied latex_renderer.rb to lib/,
  # and changed a few variables
  def get_image_from_latex(latex)
    renderer = LatexRenderer.new
    renderer.formula = latex
    filename = renderer.process
    #md5 = latex.md5hash
    blob = IO.read(filename)
    File.delete filename if File.exists? filename
    return blob
  end
  
  # this works, but seems to have reentrant problems.
  # if you try to get two images at once, it bombs out.
  def xx_get_image_from_latex(latex)
    filename = '/tmp/crabgrass-latex-' + Digest::MD5.hexdigest(latex)
    File.open(filename+'.tex', "w") {|f| f.print latex}
    IO.popen("latex -output-director /tmp "+filename+'.tex') {|io| nil while io.gets}
		img = Magick::ImageList.new(filename + '.dvi')
		img.trim!
		blob = img.to_blob {|info| info.format = 'PNG' }
		FileUtils.rm Dir.glob(filename+'*')
    return blob
  end
  
  
  @@latex_head = %q(
\documentclass[12pt]{article}
\pagestyle{empty}
\title{\LaTeX}
\date{}
\begin{document}
)

  @@latex_tail = %q(
\end{document}
)

end
