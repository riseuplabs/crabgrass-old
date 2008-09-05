
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

  #
  # Regular expressions to convert to HTML.
  #
  A_HLGN = /(?:(?:<>|<|>|\=|[()]+)+)/
  A_VLGN = /[\-^~]/
  C_CLAS = '(?:\([^)]+\))'
  C_LNGE = '(?:\[[^\]]+\])'
  C_STYL = '(?:\{[^}]+\})'
  S_CSPN = '(?:\\\\\d+)'
  S_RSPN = '(?:/\d+)'
  A = "(?:#{A_HLGN}?#{A_VLGN}?|#{A_VLGN}?#{A_HLGN}?)"
  S = "(?:#{S_CSPN}?#{S_RSPN}|#{S_RSPN}?#{S_CSPN}?)"
  C = "(?:#{C_CLAS}?#{C_STYL}?#{C_LNGE}?|#{C_STYL}?#{C_LNGE}?#{C_CLAS}?|#{C_LNGE}?#{C_STYL}?#{C_CLAS}?)"  
  TABLE_RE = /^(?:table(_?#{S}#{A}#{C})\. ?\n)?^(#{A}#{C}\.? ?\|.*?\|)(\n\n|\Z)/m
  
  # Parses Textile attribute lists and builds an HTML attribute string
  def pba( text_in, element = "", default_class='' )
    return '' unless text_in

    style = []
    text = text_in.dup
    if element == 'td'
      colspan = $1 if text =~ /\\(\d+)/
      rowspan = $1 if text =~ /\/(\d+)/
      style << "vertical-align:#{ v_align( $& ) };" if text =~ A_VLGN
    end

    style << "#{ $1 };" if not filter_styles and
      text.sub!( /\{([^}]*)\}/, '' )

    lang = $1 if
      text.sub!( /\[([^)]+?)\]/, '' )

    cls = $1 if
      text.sub!( /\(([^()]+?)\)/, '' )
                        
    style << "padding-left:#{ $1.length }em;" if
      text.sub!( /([(]+)/, '' )

    style << "padding-right:#{ $1.length }em;" if text.sub!( /([)]+)/, '' )

    style << "text-align:#{ h_align( $& ) };" if text =~ A_HLGN

    cls, id = $1, $2 if cls =~ /^(.*?)#(.*)$/
    
    cls = default_class if cls.to_s.empty? and default_class.any?
    
    atts = ''
    atts << " style=\"#{ style.join }\"" unless style.empty?
    atts << " class=\"#{ cls }\"" unless cls.to_s.empty?
    atts << " lang=\"#{ lang }\"" if lang
    atts << " id=\"#{ id }\"" if id
    atts << " colspan=\"#{ colspan }\"" if colspan
    atts << " rowspan=\"#{ rowspan }\"" if rowspan
    
    atts
  end

  # Parses a Textile table block, building HTML from the result.
  def block_textile_table( text ) 
    text.gsub!( TABLE_RE ) do |matches|

      tatts, fullrow = $~[1..2]
      tatts = pba( tatts, 'table' )
      tatts = shelve( tatts ) if tatts
      rows = []

      odd = true
      fullrow.
        split( /\|$/m ).
        delete_if { |x| x.empty? }.
        each do |row|
          default_class = odd ? 'odd' : 'even'
          if row =~ /^(#{A}#{C}\. )(.*)/m
            ratts, row = pba( $1, 'tr', default_class ), $2
          else
            ratts = " class=\"#{default_class}\""
          end
          
          cells = []
          row.split( '|' ).each do |cell|          
            ctyp = 'd'
            ctyp = 'h' if cell =~ /^_/

            catts = ''
            catts, cell = pba( $1, 'td'), $2 if 
              cell =~ /^(_?#{S}#{A}#{C}\. ?)(.*)/
            
            unless cell.strip.empty?
              catts = shelve( catts ) if catts
              cells << "\t\t\t<t#{ ctyp }#{ catts }>#{ cell }</t#{ ctyp }>" 
            end
          end
          ratts = shelve( ratts ) if ratts
          rows << "\t\t<tr#{ ratts }>\n#{ cells.join( "\n" ) }\n\t\t</tr>"
          odd = !odd
        end
      "\t<table#{ tatts }>\n#{ rows.join( "\n" ) }\n\t</table>\n\n"
    end
  end
  
end
end

