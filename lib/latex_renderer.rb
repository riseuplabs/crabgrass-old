
# MODIFIED BY elijah FOR USE WITH CRABGRASS

 # LaTeX Rendering Class
 # Copyright (C) 2003  Benjamin Zeiss <zeiss@math.uni-goettingen.de>
 #
 # This library is free software; you can redistribute it and/or
 # modify it under the terms of the GNU Lesser General Public
 # License as published by the Free Software Foundation; either
 # version 2.1 of the License, or (at your option) any later version.
 #
 # This library is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 # Lesser General Public License for more details.
 #
 # You should have received a copy of the GNU Lesser General Public
 # License along with this library; if not, write to the Free Software
 # Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 # --------------------------------------------------------------------
 # @author Benjamin Zeiss <zeiss@math.uni-goettingen.de>
 # @version v0.8
 # --------------------------------------------------------------------
 # Original URL: http://web.mit.edu/~bens/Public/latexrender/class.latexrender.php
 # Ported to Ruby (by Jan Wikholm <jw@jw.fi>
 # Ruby version 1.0
 
require 'digest/md5'
require 'rubygems'
require 'open4' # gem
require 'logger'
require 'fileutils'
class LatexRenderer
  attr_accessor :formula
  attr_reader :errors
  attr_reader :md5hash
  def initialize
    # Required external programs
    # Paths stripped of trailing newlines
    @@requisites = Hash.new
    # latex formula to dpi
    @@requisites[:latex]   = %x[which latex].strip
    # dpi to postscript (ps)
    @@requisites[:dvips]   = %x[which dvips].strip
    # postscript to image
    ## CHANGED, on debian 'convert' is 'gm convert'
    @@requisites[:convert] = %x[which gm].strip + ' convert'
    # check image's size (against size constraints)
    ## CHANGED, on debian 'identify' is 'gm identify'
    @@requisites[:identify]= %x[which gm].strip + ' identify'
    @@options = Hash.new
    # This is the DPI of the picture, as far as I can tell from
    # convert's man pages
    @@options[:density] = 120
    @@options[:size_limit_x] = 515
    @@options[:size_limit_y] = 510
    # max length of the formula
    # I dunno if there is some calculations done on the amount of
    # characters versus resolution of the image or is this just arbitrary
    @@options[:max_string_length] = 500
    @@options[:font_size] = 10 # points, not pixels
    @@options[:text_color] = 'black'
    @@options[:background_color] = 'white'
    @@options[:latex_class] = 'article'
    @@options[:image_format] = 'png'
    # I have no idea bout these commands
    # the original PHP version had them so I am taking a sure bet
    # and including them
    @@options[:blacklist_commands] = %w{include def command loop repeat open
                                        toks output input catcode name \\every
                                        \\errhelp \\errorstopmode \\scrollmode
                                        \\nonstopmode \\batchmode \\read \\write
                                        csname \\newhelp \\uppercase \\lowercase
                                        \\relax \\aftergroup \\afterassignment
                                        \\expandafter \\noexpand \\special}
    
    @log = Logger.new(File.join(RAILS_ROOT, '/log/latex.log'))
    @log.level = Logger::DEBUG
    check_requisites # may throw exceptions

    
    @formula = nil
    @errors = Array.new
  end

  def contains_blacklisted_commands?
    @@options[:blacklist_commands].each do |cmd|
      if @formula.include? cmd
        @errors.push cmd
        @log.info "%s includes: %s" % [@formula, cmd]
      end
    end
      
    return !@errors.empty?
  end
  def process
    if @formula.nil?
      @log.info "No formula given"
      raise "No formula"
    end
    if contains_blacklisted_commands?
      @log.info "Formula contains blacklisted commands: %s; formula: %s" % [@errors.join(","), @formula.gsub(/(\r\n|\n|\r)/, ';;')]
      raise "Blacklisted commands: %s" % @errors.join(",")
    end
    @md5hash = Digest::MD5.new(@formula).to_s
    @log.info "MD5: %s" % @md5hash
    # temporary filenames
    @temp_dir = File.join(RAILS_ROOT, '/tmp/')
    @final_dir = File.join(RAILS_ROOT, '/public/images/latex/')
    @temp = Hash.new
    @temp[:latex] = File.join(@temp_dir, @md5hash + '_tmp.tex')
    @temp[:dvi]   = File.join(@temp_dir, @md5hash + '_tmp.dvi')
    @temp[:ps]    = File.join(@temp_dir, @md5hash + '_tmp.ps')
    @temp[:image] = File.join(@temp_dir, @md5hash + '_tmp.' + @@options[:image_format])
    @temp[:aux]   = File.join(@temp_dir, @md5hash   + '_tmp.aux')
    @temp[:latex_log] = File.join(@temp_dir, @md5hash + '_tmp.log')
    # final filename
    #@filename = File.join(@final_dir, @md5hash + '.' + @@options[:image_format])
    ## CHANGED: we use a different method of caching.
    @filename = File.join(@temp_dir, @md5hash + '.' + @@options[:image_format])
    
    @log.info "Filename: %s" % @filename
    if File.exists?(@filename)
      @log.info "File already exists"
      return @filename
    else
      @log.info "File doesn't exist. let's make it"
      begin
        render_from_latex_to_image
        if @errors.empty?
          @log.info "File creation successfull"
          return @filename
        else
          @log.info "File creation failed (%s)" % @errors.join("\n")
          raise "The following errors occurred:" + @errors.join("\n")
        end
      rescue => e
        @log.info "Render failed.\n#{e.to_s}\n#{e.backtrace.join("\n")}"
        raise "Render failed.\n#{e.to_s}\n#{e.backtrace.join("\n")}"
      ensure
        cleanup
      end
    end
  end
  def cleanup
    @temp.each_value do |file|
      if File.exists? file
        if File.delete file
          @log.info "%s deleted" % file.to_s
        else
          @log.info "%s could not be deleted" % file.to_s
        end
      end
    end
  end
  

  def render_from_latex_to_image
    ## CHANGE: skip the wrapping, do it ourselves elsewhere.
    #wrapped_formula = wrap_formula(@formula)
    wrapped_formula = @formula
    @log.info wrapped_formula
    
    # temp Latex file
    File.open(@temp[:latex], 'w') do |file|
      file.write wrapped_formula
    end
    
    # temp dvi file
    from_latex_to_dpi = run_command("#{@@requisites[:latex]} --output-directory=#{@temp_dir} --interaction=nonstopmode #{@temp[:latex]}", "Conversion from Latex to DPI")
    
    #convert dvi to ps using dvips
    from_dpi_to_ps = run_command("#{@@requisites[:dvips]} -E #{@temp[:dvi]} -o #{@temp[:ps]}", "Conversion from DPI to PS")

    # black+white, fast special case
    if @@options[:text_color] =~ /black|000000/ && @@options[:background_color] =~ /white|ffffff/
      # convert -density xyz -trim -transparent "#FFFFFF" 123_tmp.ps 123_tmp.png
      final_cmd = sprintf('%s -density %s -trim -transparent "#FFFFFF" %s %s',
                          @@requisites[:convert],
                          @@options[:density].to_s,
                          @temp[:ps],
                          @temp[:image]
                          )
    # full alpha-blending
    elsif @@options[:image_format] == 'png'
      # convert ( 
      #           ( 
      #             ( 
      #               -density xyz 123_tmp.ps -trim 
      #             ) ( 
      #               +clone -negate 
      #             ) -compose CopyOpacity 
      #           ) -composite 
      #         ) -channel RGB -fx "white" 123_tmp.png
      final_cmd = sprintf('%s \( \( \( -density %s %s -trim \) \( +clone -negate \) -compose CopyOpacity \)' + \
                          ' -composite \) -channel RGB -fx "%s" %s',
                          @@requisites[:convert],
                          @@options[:density].to_s,
                          @temp[:ps],
                          @@options[:text_color],
                          @temp[:image]
                          )

    # approximate alpha-blendin
    else
      # convert (
      #           -density xyz 123_tmp.ps -trim
      #         ) (
      #           -clone 0 fx "bgcolor"
      #         ) (
      #           -clone 0 fx "fgcolor"
      #         ) -swap 0,2 -composite -transparent "bgcolor"  123_tmp.png
      final_cmd = sprintf('%s \( -density %s %s -trim \) \( -clone 0 -fx "%s" \) \( -clone 0 -fx "%s" \) -swap 0,2 -composite -transparent "%s" %s',
                          @@requisites[:convert],
                          @@options[:density].to_s,
                          @temp[:ps],
                          @@options[:background_color],
                          @@options[:text_color],
                          @@options[:background_color],
                          @temp[:image]
                          )
    end

    final_result = run_command(final_cmd, "Conversion from PS to final image")
    
    dimensions = get_dimensions(@temp[:image])
    if (dimensions[0] > @@options[:size_limit_x] || dimensions[1] > @@options[:size_limit_y])
      raise "Image's dimensions excede constraint dimensions #{dimensions.join('x')}"
    end

    FileUtils.copy @temp[:image], @filename



    return true
  end

  def wrap_formula(formula)
    @log.info Dir.pwd
    #wrapped = IO.readlines(File.join(File.dirname(__FILE__), 'template.tex')).join
    wrapped = %q(\documentclass[FONTSIZEpt]{LATEXCLASS}
\pagestyle{empty}
\begin{document}
\LARGE
FORMULA
\end{document}
)
    wrapped.gsub!('FONTSIZE', @@options[:font_size].to_s)
    wrapped.gsub!('LATEXCLASS', @@options[:latex_class])
    wrapped.gsub!('FORMULA', formula)
  end

  def get_dimensions(filename)
    output = run_command("#{@@requisites[:identify]} #{filename}", "Getting dimensions from generated image")
    
    dimensions = output.split(/ /)[2].split('x')
    [dimensions[0].to_i, dimensions[1].to_i]
  end

  def check_requisites
    @log.info "checking requisites"
    missing_progs = []
    @@requisites.each_pair do |key,value|
      missing_progs << key.to_s if value.empty?
      @log.info "Missing: " + key.to_s if value.empty?
    end
    raise "Missing requirements: #{missing_progs.join(' ')}" if !missing_progs.empty?
    @log.info "requisites OK"
  end

  def run_command(str,msg=nil)
    @log.info "Executing #{str}"

    pid, stdin, stdout, stderr = Open4::popen4 str
    ignored, status = Process::waitpid2 pid
    err = stderr.readlines.join("\n")
    output = stdout.readlines.join("\n")
    # close all pipes to avoid leaks - har har
    [stdin,stdout,stderr].each{|pipe| pipe.close}
    
    if status.exitstatus == 1
      message = msg + " failed.\n #{str} caused the following error(s)\n#{err}"
      raise message
    end
    return output
  end
end
