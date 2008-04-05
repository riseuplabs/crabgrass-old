module Greencloth
module Inline

  private
 
    ###############################################################3
  # INLINE FILTERS
  #
  # Here lie the greencloth inline filters. An inline filter
  # processes text within a block.
  #
  
  def xglyphs_textile( text, level = 0 )
    if text !~ HASTAG_MATCH
      pgl text
    else
      text.gsub!( ALLTAG_MATCH ) do |line|
        if $1.nil?
          glyphs_textile( line, level + 1 )
        end
        line
      end
    end
  end
  
  CRABGRASS_LINK_RE = /
    (^|.)         # start of line or any character
    \[            # begin [
    [ \t]*        # optional white space
    ([^\[\]]+)    # $text : one or more characters that are not [ or ]
    [ \t]*        # optional white space
    \]            # end ]
  /x 

  def inline_crabgrass_link( text ) 
    text.gsub!( CRABGRASS_LINK_RE ) do |m|
      preceding_char, text = $~[1..2]
      if preceding_char == '\\'
        $~[0].sub('\\[', '[').sub('\\]', ']')
      else
        # $text = "from -> to"
        from, to = text.split(/[ ]*->[ ]*/)[0..1]
        to ||= from # in case there is no "->"
        if to =~ /^(\/|https?:\/\/)/
          # assume $to is an absolute path or full url
          atts = " href=\"#{to}\""
          text = from
        else
          # $to = "group_name / page_name"
          group_name, page_name = to.split(/[ ]*\/[ ]*/)[0..1]
          unless page_name
            # there was no group indicated, so $group_name is really the $page_name
            page_name = group_name
            group_name = @default_group
          end
          text = from =~ /\// ? page_name : from
          atts = " href=\"/#{nameize group_name}/#{nameize page_name}\""
        end
        atag = bypass_filter("<a#{ atts }>#{ text }</a>")
        "#{preceding_char}#{atag}"
      end
    end
  end
  
  # eventually, it would be nice to support link titles
  # and references:
  #   atts << " title=\"#{ title }\"" if title
  #   atts = shelve( atts )  
  
  
  #
  # characters that might be found in a valid URL
  # according to the RFC, although some are rarely
  # seen in the wild.
  #
  # alphnum: a-z A-Z 0-9 
  #    safe: $ - _ . +
  #   extra: ! * ' ( ) ,
  #  escape: %
  #
  # additionally, the "~" character is common although expressly
  # excluded from the list of valid characters in the RFC. go figure.
  #
  
  URL_CHAR = '\w' + Regexp::quote('+%$*\'()-~')
  URL_PUNCT = Regexp::quote(',.;:!')
  
  AUTO_LINK_RE = %r{
    (                          # leading text
      <\w+.*?>|                # leading HTML tag, or
      [^=!:'"/]|               # leading punctuation, or
      ^                        # beginning of line
    )
    (
      (?:https?://)|           # protocol spec, or
      (?:www\.)                # www.*
    )
    (
      [-\w]+                   # subdomain or domain
      (?:\.[-\w]+)*            # remaining subdomains or domain
      (?::\d+)?                # port
      (?:/(?:(?:[#{URL_CHAR}]|(?:[#{URL_PUNCT}][^\s$]))+)?)* # path
      (?:\?[\w\+%&=.;-]+)?     # query string
      (?:\#[\w\-]*)?           # trailing anchor
    )
    ([[:punct:]]|\s|<|$)       # trailing text
  }x

  # 
  # auto links are extracted and put in @pre_list so they
  # can escape the inline filters.
  #                       
  def inline_auto_link_urls(text)
    text.gsub!(AUTO_LINK_RE) do
      all, a, b, c, d = $&, $1, $2, $3, $4
      if a =~ /<a\s/i # don't replace URL's that are already linked
        all
      else
        text = truncate c, 42
        url = %(#{b=="www."?"http://www.":b}#{c})
        link = bypass_filter( %(<a href="#{url}">#{text}</a>) )
        %(#{a}#{link}#{d})
      end
    end
  end

  # I'm over-writing this function (copied from redcloth.reference.rb) 
  # to make images get their own div with style="overflow: auto;"
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
    # PUNCT = Regexp::quote( '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~' )
    PUNCT = Regexp::quote( '!"#$%&\'*+,-./:;=?@\\^_`|~' )
    PUNCT_NOQ = Regexp::quote( '!"#$&\',./:;=?@\\`|' )
    PUNCT_Q = Regexp::quote( '*-_+^~%' )
    HYPERLINK = '(\S+?)([^\w\s/;=\?]*?)(?=\s|<|$)'

  IMAGE_RE = /
          (<p>|.|^)            # start of line?
          \!                   # opening
          (\<|\=|\>)?          # optional alignment atts
          (#{C})               # optional style,class atts
          (?:\. )?             # optional dot-space
          ([^\s(!]+?)          # presume this is the src
          \s?                  # optional space
          (?:\(((?:[^\(\)]|\([^\)]+\))+?)\))?   # optional title
          \!                   # closing
          (?::#{ HYPERLINK })? # optional href
      /x 

    def inline_crabgrass_image( text ) 
        text.gsub!( IMAGE_RE )  do |m|
            stln,algn,atts,url,title,href,href_a1,href_a2 = $~[1..8]
            atts = pba( atts )
            atts = " src=\"#{ url }\"#{ atts }"
            atts << " title=\"#{ title }\"" if title
            atts << " alt=\"#{ title }\"" 
            # size = @getimagesize($url);
            # if($size) $atts.= " $size[3]";

            href, alt_title = check_refs( href ) if href
            url, url_title = check_refs( url )

            out = ''

            # added line here --af
            out << '<div style="overflow: auto;">'
            
            out << "<a#{ shelve( " href=\"#{ href }\"" ) }>" if href
            out << "<img#{ shelve( atts ) } />"
            out << "</a>#{ href_a1 }#{ href_a2 }" if href
            
            #added another line here --af
            out << '</div>'
            
            if algn 
                algn = h_align( algn )
                if stln == "<p>"
                    out = "<p style=\"float:#{ algn }\">#{ out }"
                else
                    out = "#{ stln }<div style=\"float:#{ algn }\">#{ out }</div>"
                end
            else
                out = stln + out
            end

            out
        end
    end
end
end

