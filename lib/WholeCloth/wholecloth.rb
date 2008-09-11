
require 'rubygems'
require File.join(File.expand_path(File.dirname(__FILE__)), "RedCloth", "lib", "redcloth")#modified redcloth 4

class WholeCloth < RedCloth::TextileDoc
  
  MARKDOWN_BQ_RE = /(^ *> ?.+$(.+\n)*\n*)+/
    
  def crabgrass_markdown_bq( text )
    text.gsub!( MARKDOWN_BQ_RE ) do |blk|
      blk.gsub!( /^ *> ?/, '' )
      flush_left blk
      blk.gsub!( /^(\S)/, "\t\\1" ) # add two leading spaces for readability.
      "<blockquote>\n#{ blk }\n</blockquote>\n\n"
    end
  end
    def flush_left( text )
        indt = 0
        if text =~ /^ /
            while text !~ /^ {#{indt}}\S/
                indt += 1
            end unless text.empty?
            if indt.nonzero?
                text.gsub!( /^ {#{indt}}/, '' )
            end
        end
    end
  
  CG_CODE_BEGIN = Regexp::quote('/--')
  CG_CODE_END = Regexp::quote('\--')
  CRABGRASS_MULTI_LINE_CODE_RE = /^#{CG_CODE_BEGIN}( +[^\n]*)?(\n.*\n)#{CG_CODE_END}(\n|$)/m
  CRABGRASS_SINGLE_LINE_CODE_RE = /^@@( )(.*)$/
  CRABGRASS_CODE_RE = Regexp::union(CRABGRASS_MULTI_LINE_CODE_RE, CRABGRASS_SINGLE_LINE_CODE_RE)
  def crabgrass_code( text )
    text.gsub!( CRABGRASS_CODE_RE ) do |blk|
      body = $2||$5
      note = $1||$4  
      bypass_filter( format_block_code("<code #{note}>", body) )
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

  def crabgrass_link( text ) 
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
  
  URL_CHAR = '\w' + Regexp::quote('+%$*\'()-~')
  URL_PUNCT = Regexp::quote(',.;:!')
  AUTO_LINK_RE = %r{
    (                          # (a)leading text
      <\w+.*?>|                # leading HTML tag, or
      [^=!:'"/]|               # leading punctuation, or
      ^                        # beginning of line
    )
    (               #(b)  
      (?:https?://)|           # protocol spec, or
      (?:www\.)                # www.*
    )
    (               #(c)
      [-\w]+                   # subdomain or domain
      (?:\.[-\w]+)*            # remaining subdomains or domain
      (?::\d+)?                # port
      (?:/(?:(?:[#{URL_CHAR}]|(?:[#{URL_PUNCT}][^\s$]))+)?)* # path
      (?:\?[\w\+%&=.;-]+)?     # query string
      (?:\#[\w\-\.]*)?           # trailing anchor
    )
    (\1|\s|<|$)       # (d)trailing text
  }x
  def crabgrass_auto_link(text)
    text.gsub!(AUTO_LINK_RE) do
      all, a, b, c, d = $&, $1, $2, $3, $4
      if a =~ /<a\s/i # don't replace URL's that are already linked
        all
      else
      if a[0..0] =~ /[-~+_*]/ and c[-1..-1] =~ /[-~+_*]/ #match formatting characters and don't autolink them if the same one exists on both sides
        d = a[0..0]
        c.chop! #omnomnomnom
      end
      text = truncate c, 42
      url = %(#{b=="www."?"http://www.":b}#{c})
      link = %(<a href="#{url}">#{text}</a>) 
      link_placeholder = bypass_filter("#{link}")
      "#{a}#{link_placeholder}#{d}"
      end
    end
  end
  
  SETEXT_RE = /^(.+?)\n([=-])[=-]* *$/m
  def crabgrass_setext_header(text)
    text.gsub!(SETEXT_RE) do
      tag = $2=="=" ? "h1" : "h2"
      "<#{ tag }>#{ $1 }</#{ tag }>"
    end
  end
  
  OFFTAG_RE = /\{wholecloth#([\d]+)\}/#matches $1 to id
  def initialize(string, default_group_name = 'page')
    @offtag_list = []
    @default_group = default_group_name
    string.gsub!(OFFTAG_RE,'')#filter out phony offtags
    super( string, [:hard_breaks, :sanitize_html] )
  end
 
  def to_html(*options, &block)
    @block = block
    options += [:crabgrass_offtags, :crabgrass_link, :crabgrass_auto_link, :crabgrass_code, :crabgrass_markdown_bq, :crabgrass_setext_header]
    html = super(*options)
    html.gsub!(OFFTAG_RE) do |m|
    @offtag_list[$1.to_i-1]#replace offtag with the corresponding entry
  end
  html
  end
  
  def bypass_filter(text)
    @offtag_list << text
    %Q({wholecloth##{@offtag_list.length}})
  end
  
  def htmlesc( str, mode )
  str.gsub!( '&', '&amp;' )
  str.gsub!( '"', '&quot;' ) if mode != :noQuotes
  str.gsub!( "'", '&#039;' ) if mode == :Quotes
  str.gsub!( '<', '&lt;')
  str.gsub!( '>', '&gt;')
  end
  
  ##############################################
  ## OFFTAGS: when greencloth does not apply

  # changed from redcloth values
  OFFTAGS = /(code|pre)/
  OFFTAG_MATCH = /(.?)(?:(<\/#{ OFFTAGS }>)|(<#{ OFFTAGS }[^>]*>))(.*?)(<\/?\5>|\Z)/mi
  #OFFTAG_MATCH = /(?:(<\/#{ OFFTAGS }>)|(<#{ OFFTAGS }[^>]*>))(.*?)(<\/?\4>|\Z)/mi
  # the key is the backreference for matching the closing tag
  
  def crabgrass_offtags( text )
    text.gsub!( OFFTAG_MATCH ) do |line|
      leading_character = $1
      tag        = $4  # eg '<code>'
      codebody   = $6  # eg 'there'
      leading_character + bypass_filter( format_block_code(tag, codebody, leading_character) )
    end
  end
  
  def format_block_code(tag, body, leading_character='')
    tag.match /<(#{ OFFTAGS })\s*([^>]*)\s*>/
    tagname, arg = $1, $3
    if (leading_character.any? and leading_character!="\n") or tagname == 'pre'
      ret = "<#{tagname}>#{body.strip}</#{tagname}>"
    else
      htmlesc(body, :noQuotes)
      ret = "<pre class='code'>#{body.strip}</pre>"
    end
    if arg.any?
      ret = "<div class=\"#{tagname}title\">#{arg}</div>\n#{ret}"
    end
    ret
  end
  
  # 
  # convert text so that it is in a form that matches our 
  # convention for page names and group names:
  # - all lowercase
  # - no special characters
  # - replace spaces with hypens
  # 
  def nameize(text)
    text.strip.downcase.gsub(/[^-a-z0-9_ \+]/,'').gsub(/[ ]+/,'-') if text
  end
  
  # from actionview texthelper
  def truncate(text, length = 30, truncate_string = "...")
    if text.nil? then return end
    l = length - truncate_string.length
    text.length > length ? text[0...l] + truncate_string : text
  end
end
