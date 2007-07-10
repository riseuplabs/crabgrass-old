
module Greencloth
module Block

  private
  
  #####################################################
  # BLOCK FILTERS
  #
  # Here in lie the custom GreenCloth block filters. These
  # are filters that do block level formatting, like lists
  # blockquotes, tables, etc.
 

  #
  # Dictionary entries look like this:
  # 
  # term
  #   entry one
  #   entry two
  #
  
  DICTIONARY_RE = /\A([^<\n]*)\n^( +.*)/m
  # start of string
  # title line is anything but < and \n
  # followed by definition lines that start with
  # one or more spaces 
  
  def block_dictionary( text )
    text.gsub!( DICTIONARY_RE ) do |blk|
      title = $1
      definitions = $2.gsub(/^ +(.*)$/) do |dd|
        "<dd>#{$1}</dd>"
      end
      "<dl>\n<dt>#{title}</dt>\n#{definitions}\n</dl>"
    end
  end

  MARKDOWN_BQ_RE = /\A(^ *> ?.+$(.+\n)*\n*)+/m
    
  def block_markdown_bq( text )
    text.gsub!( MARKDOWN_BQ_RE ) do |blk|
      blk.gsub!( /^ *> ?/, '' )
      flush_left blk
      blocks blk, false, true
      blk.gsub!( /^(\S)/, "\t\\1" ) # add two leading spaces for readability.
      "<blockquote>\n#{ blk }\n</blockquote>\n\n"
    end
  end

  # crabgrass code blocks look like this:
  #   /--
  #   here is some code
  #   \--
  # they work the same as <code>
  
  CG_CODE_BEGIN = Regexp::quote('/--')
  CG_CODE_END = Regexp::quote('\--')
  CRABGRASS_MULTI_LINE_CODE_RE = /^#{CG_CODE_BEGIN}( +[^\n]*)?(\n.*\n)#{CG_CODE_END}(\n|$)/m
  CRABGRASS_SINGLE_LINE_CODE_RE = /^@@( )(.*)$/
  CRABGRASS_CODE_RE = Regexp::union(CRABGRASS_MULTI_LINE_CODE_RE, CRABGRASS_SINGLE_LINE_CODE_RE)
  def block_crabgrass_code( text )
    text.gsub!( CRABGRASS_CODE_RE ) do |blk|
      body = $2||$5
      note = $1||$4
      htmlesc( body, :NoQuotes )  
      bypass_filter( format_block_code("<code #{note}>", body) )
    end
  end

  LATEX_BLOCK_RE = /(^|\n)\$\$\n(.*)\n\$\$($|\n)/m
  def block_latex( text )
    text.gsub!( LATEX_BLOCK_RE ) do |blk|
      if blk
        latex = $2
        # the & characters have been previously converted to x%x%, so revert them back.
        latex.gsub!( /x%x%/, '&' )
        url = encode_and_compress_url_data(latex)
        imgtag = bypass_filter("<img src='/latex/#{url}.png'>")
        "\n<p>#{imgtag}</p>\n"
      end
    end
  end
  
end
end

