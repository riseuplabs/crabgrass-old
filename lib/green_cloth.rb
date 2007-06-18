#
# GreenCloth
# ==========
# 
# GreenCloth is a simple subclass customization of RedCloth, which is the defacto
# text to html converter for ruby, based on a combination of the rules from Textile
# and Markdown. Textile is designed for full html control, but using 'prettier' inline
# markup, where as Markdown is designed to look just as good in plain text mode as in
# formatted html. 
# 
# GreenCloth is intended to work with Crabgrass: it's linking system
# does not apply to other programs.
# 
# GreenCloth changes from RedCloth:
# 
# - links and references are in a totally different format
# - when specifying 'atx-style' headers, more # means a bigger header.
# - horizontal rules are disabled
# - no inline html is allowed
# - hard breaks
#   - created by short line
#   - can be forced by ending with a space
#   - can be disabled by ending with a hypen
#
# GreenCloth links
#
# [A good page]                  ---> <a href="/mygroup/a-good-page">A good page</a>
# [I like pages -> A good page]  ---> <a href="/mygroup/a-good-page">I like pages</a>
# [I like pages -> 2452]         ---> <a href="/mygroup/2452">I like pages</a>
# [other group/A good page]      ---> <a href="/other-group/a-good-page">A good page</a>
# [I like pages -> other-group/] ---> <a href="/other-group/i-like-pages">I like pages</a>
# http://riseup.net              ---> <a href="http://riseup.net">riseup.net</a>
#
#
#
# Here are the specific Redcloth rules we have enabled (marked with !):
# 
# textile rules
#   http://hobix.com/textile/
#   :textile               all the following textile rules, in that order
#   :refs_textile          Textile references (i.e. [hobix]http://hobix.com/)
# ! :block_textile_table   Textile table block structures. eg: |a|b|c|
# ! :block_textile_lists   Textile list structures. eg: * item\n** inset item
# ! :block_textile_prefix  Textile blocks with prefixes (i.e. bq., h2., etc.)
# ! :inline_textile_image  Textile inline images
#   :inline_textile_link   Textile inline links
# ! :inline_textile_span   Textile inline spans
# ! :glyphs_textile        Textile entities (such as em-dashes and smart quotes)
#
# markdown rules
#   http://daringfireball.net/projects/markdown/syntax
#   :markdown             all the following markdown rules, in that order.
#   :refs_markdown         Markdown references.       eg: [hobix]: http://hobix.com/
# ! :block_markdown_setext Markdown setext headers.   eg: ---- or =====
#   :block_markdown_atx    Markdown atx headers.      eg: ### or ##
#   :block_markdown_rule   Markdown horizontal rules. eg: * * *, or ***, or ----, or - - -
# ! :block_markdown_bq     Markdown blockquotes.      eg: > indented
#   :block_markdown_lists  Markdown lists.            eg: -, *, or +, or 1.
#   ^^^^  NOT YET WORKING as of redcloth 3.0.4
#   :inline_markdown_link  Markdown links.            eg: [This link](http://example.net/), or <http://example.net>
# 
# Redcloth restrictions: 
# 
# ! :filter_html   does not allow html to get passed through. (not working in redcloth
#                  so disabled)
#   :hard_breaks   single newlines will be converted to HTML break tags.
#

class GreenCloth < RedCloth

  # override default rules
  DEFAULT_RULES = [
    :block_markdown_setext, 
    :block_textile_table,
    :block_textile_lists,
    :block_textile_prefix,
    :block_markdown_bq,
    :inline_crabgrass_link,
    :inline_textile_image,
    :inline_textile_code,
    :inline_textile_span,
    :inline_auto_link_urls,
    :glyphs_textile
  ]

  def initialize(string, default_group_name = 'page')
    # html cleaning in redcloth is reportedly broken, and i can't
    # get it working either, so here it is disabled for good measure.
    @filter_html = false 
    @hard_breaks = true
    @default_group = default_group_name
    super( escape_html_tags(string) )
  end
  
  def to_html(*rules)
    super(DEFAULT_RULES)
  end
  
  private
  
  # change hard breaks:
  # - force break if line ends with a space
  # - only break on short lines (not working yet!)
  # - force continuation if line ends with a \ (not working yet!)
 
  #SHORT_LINE_RE = /^.{1,40}\n/
  #END_SPACE_RE = /^ {1,}\n/
  #HARD_BREAK_RE = Regexp.union(SHORT_LINE_RE, END_SPACE_RE)
  def hard_break( text )
    text.gsub!( / \n(?!\Z| *([#*=]+(\s|$)|[{|]))/, "\\1<br/>\n" ) if hard_breaks
    #text.gsub!( HARD_BREAK_RE, "\\0(((br)))\n" )
  end
  
  #
  # the clean_html function of redcloth seems to not work, and is reported by others to 
  # not work. I don't understand what the code is trying to do anyway. 
  # So, we have added our own simple filter to simply escape < >
  #
  # TODO: this breaks <pre> blocks, which is the only way to do code blocks in textile.
  #
  # TODO: bluecloth actually goes through the work of parsing the html
  # to find matching tags and raises an error if a tag is not properly closed.
  # If we wanted to allow some html, it seems like a good idea to do something
  # like that.
  #
  def escape_html_tags( text )
    text.gsub( "<", "&lt;" ) #.gsub( ">", "&gt;" )
  end

  # override internal redcloth function so that <pre><b>hi</b></pre> doesn't escape "<" twice
  # this is super hacky and bad, but what to do....
  def htmlesc( str, mode )
     str.gsub!( '&lt;', '<')
     #str.gsub!( '&gt;', '>')
     super(str, mode)
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
        "#{preceding_char}<a#{ atts }>#{ text }</a>"
      end
    end
  end
  
  # eventually, it would be nice to support link titles
  # and references:
  #   atts << " title=\"#{ title }\"" if title
  #   atts = shelve( atts )  
  
  # 
  # convert text so that it is in a form that matches our 
  # convention for page names and group names:
  # - all lowercase
  # - no special characters
  # - replace spaces with hypens
  # 
  def nameize(text)
    text.downcase.gsub(/[^-a-z0-9 \+]/,'').gsub(/[ ]+/,'-') if text
  end
    
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
      (?:/(?:(?:[~\w\+%-]|(?:[,.;:][^\s$]))+)?)* # path
      (?:\?[\w\+%&=.;-]+)?     # query string
      (?:\#[\w\-]*)?           # trailing anchor
    )
    ([[:punct:]]|\s|<|$)       # trailing text
  }x
                       
  def inline_auto_link_urls(text)
    extra_options = ""
    text.gsub!(AUTO_LINK_RE) do
      all, a, b, c, d = $&, $1, $2, $3, $4
      if a =~ /<a\s/i # don't replace URL's that are already linked
        all
      else
        text = truncate c, 42
        %(#{a}<a href="#{b=="www."?"http://www.":b}#{c}"#{extra_options}>#{text}</a>#{d})
      end
    end
  end
  
  # from actionview texthelper
  def truncate(text, length = 30, truncate_string = "...")
    if text.nil? then return end
    l = length - truncate_string.chars.length
    text.chars.length > length ? text.chars[0...l] + truncate_string : text
  end
   
end

