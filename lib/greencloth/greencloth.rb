=begin

passing a block to to_html()
-----------------------------

  html = GreenCloth.new(test_text,'mygroup').to_html() do |link|
    link_is_valid(link)
  end

custom GreenCloth filters, without messing up <code> blocks
------------------------------------------------------------

We need to be able to apply global filters to the text, but we don't want our
filters to apply preformatted code. Greencloth does not let us intervene in
the filtering process to just apply something to non-code blocks (or to just
apply to code blocks). It comes close, but there is a bug in the way escape_pre
is called.

Some problems: 

* We can't just run our filters before redcloth, because then the filters will
  apply to code blocks.

* We could un-offtag code blocks after they have been offtagged by a global
  greencloth filter, but escape_pre often gets a single char at a time, so it
  won't work.

* we could do the un-offtagging in formatter code(), pre(), and snip(), but these
  are only sometimes called.

* we can't apply custom greencloth filters in formatter.p(), because auto links
  might have already been messed up by redcloth entity formatting.

So, this is our strategy:

(1) first, we offtag the obvious code blocks.

(2) then we apply our custom greencloth filters.

    a. one of the things these filters do is to offtag all the greencloth and 
       auto rul links. this is necessary at this stage so that redcloth can't
       mess up the urls

(3) redcloth transformations are run

    a. if the formatter discovers code blocks during the redcloth run, we
       remove any offtags from those blocks (since the code block must not have
       formatting and the offtags is from our previous pass looking for
       greencloth links). This happens i GreenClothFormatterHTML.code().

offtags
----------------------------------

offtags work like this:

  "<p>hello <code>there</code></p>"
  "<p>hello <code>{offtag#1}</code></p>"

=end

require 'rubygems'
require 'RedCloth'

require 'redcloth/formatters/html'
module GreenClothFormatterHTML
  include RedCloth::Formatters::HTML

  # alas, so close, but so far away. most times this is called with a single
  # char at a time, so this won't work:
  #def escape_pre(text)
  #  original.revert_offtags(text)
  #  original.offtag_it html_esc(text, :html_escape_preformatted)
  #end

  def code(opts)
    "<code#{pba(opts)}>%s</code>" % original.revert_offtags(opts[:text])
  end

  # add class='left' or class='right' to <p> to make it possible to set the
  # margins in the stylesheet. 
  def p(opts)
    klass = opts[:float] ? ' class="%s"'%opts[:float] : ''
    "<p#{pba(opts)}#{klass}>#{opts[:text]}</p>\n"
  end

  ALLOWED_HTML_TAGS_RE = /<\/?(blockquote|em|strong|pre|code)>/

  def inline_html(opts)
    if opts[:text] =~ ALLOWED_HTML_TAGS_RE
      "#{opts[:text]}" # nil-safe
    else
      html_esc(opts[:text], :html_escape_preformatted)    
    end
  end
    
end

class GreenCloth < RedCloth::TextileDoc

  OFFTAG_PREFIX = 'offtag'
  OFFTAG_RE = /\{#{OFFTAG_PREFIX}#([\d]+)\}/  # matches {offtag#55} -> $1 == 55

  attr_accessor :original
  attr_accessor :offtags
  attr_accessor :formatter

  def initialize(string, default_group_name = 'page')
    @default_group = default_group_name
    super(string)
  end

  # RedCloth calls clone of the GreenCloth object before 
  # extending the object with the formatter. We want to be able
  # to reference the original object (so we can keep an offtags list)
  def initialize_copy(arg)
    super(arg)
    self.original = arg
    arg.formatter = self
  end

  def to_html(*before_filters, &block)
    @block = block
    before_filters += [:normalize_code_blocks, :offtag_obvious_code_blocks,
      :bracket_links, :auto_links, :headings, :embedded, :quoted_block,
      :tables_with_tabs]

    formatter = self.clone()                   # \  in case one of the before filters
    formatter.extend(GreenClothFormatterHTML)  # /  needs the formatter.

    apply_rules(before_filters)
    html = to(GreenClothFormatterHTML)
    extract_offtags(html)

    return html
  end

  def apply_inline_filters(text)
    bracket_links(text)
    auto_links(text)
    text
  end

  # allow setext style headings
  HEADINGS_RE = /^(.+?)\r?\n([=-])[=-]+ */
  def headings(text)
    text.gsub!(HEADINGS_RE) do
      tag = $2=="=" ? "h1" : "h2"
      "#{ tag }. #{$1}\n\n"
    end
  end

  ##
  ## CODE
  ##

  # sometimes we like exactly what RedCloth does, but we would like to change
  # the syntax slightly. In these cases, we simply modify the source text to
  # replace the greencloth markup with the equivelent redcloth markup before
  # any other processing is done.

  def normalize_code_blocks(text)
    ## make funky code blocks behave like a normal code block.
    text.gsub!(/^\/--( .*)?\s*$/, '<code\1>')
    text.gsub!(/^\\--\s*$/, '</code>')

    ## convert <code title> to "codetitle. title\n\n<code>"
    text.gsub!(/^<code ([^>]+)>\s*$/, "codetitle. \\1\n\n<code>")

    ## make @@ be just like "bc."
    text.gsub!(/^@@\s/, 'bc. ')
  end

  # this is called automatically when line starts with "codetitle."
  def codetitle(opts)
    %(<div class="codetitle">%s</div>\n) % opts[:text]
  end

  CODE_TAGS = /(code|pre)/
  CODE_TAG_RE = /(.?)(?:(<\/?#{ CODE_TAGS }[^>]*>))(.*?)(<\/?\3>|\Z)/mi

  def offtag_obvious_code_blocks( text )
    text.gsub!( CODE_TAG_RE ) do |line|
      leading_character = $1
      tag        = $2  # eg '<code>'
      codebody   = $4  # what is between <code> and </code>
      leading_character + format_block_code(tag, codebody, leading_character)
    end
  end

  def format_block_code(tag, body, leading_character='')
    body = self.formatter.html_esc(body, :html_escape_preformatted)
    body.gsub!(/\A\r?\n/,'')
    # ^^^ get ride of leading returns. This makes it so the text in
    # <pre> doesn't appear in the browser with an empty first line.
    offtag = offtag_it(body)
    if tag == '<pre>' or (leading_character.any? and leading_character!="\n")
      "#{tag}#{offtag}#{tag.sub('<','</')}"
    else      
      "<pre><code>#{offtag}</code></pre>"
    end
  end

  ##
  ## BLOCKS
  ##

  # blockquotes
  QUOTED_BLOCK_RE = /(^>.*$(.+\n)*\n*)+/
    
  def quoted_block( text )
    text.gsub!( QUOTED_BLOCK_RE ) do |blk|
      blk.gsub!(/^> ?/, '')
      flush_left blk
      "<blockquote>#{blk}</blockquote>\n"
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

  TABLE_TABS_RE = /^\t.*\t$/
  def tables_with_tabs( text )
    text.gsub!( TABLE_TABS_RE ) do |row|
      row.gsub /\t/, '|'
    end
  end

  ##
  ## OFFTAGS
  ##

  def offtag_it(text, original='')
    @count ||= 0
    @offtags ||= []
    @count += 1
    @offtags << [text, original]
    '{offtag#%s}' % @count
  end
  def extract_offtags(html)
    html.gsub!(OFFTAG_RE) do |m|
      str = self.offtags[$1.to_i-1][0] # replace offtag with the corresponding entry
    end
    html
  end

  # replace offtag with the original text
  def revert_offtags(html)
    html.gsub!(OFFTAG_RE) do |m|
      #puts m.inspect; puts self.offtags
      str = self.offtags[$1.to_i-1][1] 
    end
    html
  end

  ##
  ## LINKS
  ##

  # hyperlinks to external pages
  URL_CHAR = '\w' + Regexp::quote('+%$*\'()-~')
  URL_PUNCT = Regexp::quote(',.;:!?')
  PROTOCOL = '(?:sips?|https?|s?ftps?)'
  AUTO_LINK_RE = %r{
    (                          # (a) LEADING TEXT
      <\w+.*?>|                # leading HTML tag, or
      [^=!:'"/]|               # 'leading punctuation, or
      ^                        # beginning of line
    )
    (                          # (b) PROTOCOL 
      (?:#{PROTOCOL}s?://)|    # protocol spec, or
      (?:www\.)                # www.*
    )
    (                          # (c) URL
      [-\w]+                   # subdomain or domain
      (?:\.[-\w]+)*            # remaining subdomains or domain
      (?::\d+)?                # port
      (?:/(?:(?:[#{URL_CHAR}]|(?:[#{URL_PUNCT}][^\s$]))+)?)* # path
      (?:\?[\w\+%&=.;-]+?)?    # query string
      (?:\#[\w\-\.]*)?         # trailing anchor
    )?
    (\1|$|[#{URL_PUNCT}](\s|$))  #(d) TRAILING TEXT
  }x

  def auto_links(text)
    text.gsub!(AUTO_LINK_RE) do
      all, a, b, c, d = $&, $1, $2, $3, $4
      if a =~ /<a\s/i # don't replace URL's that are already linked
        all
      else
        first_char = a[0..0]
        if first_char =~ BRACKET_FORMATTERS and (first_char == c[-1..-1])
          # match formatting characters and don't autolink them if the same one exists on both sides
          d = first_char
          c.chop! # remove last char from c.
        end
        text = truncate c, 42
        url = %(#{b=="www."?"http://www.":b}#{c})
        a + offtag_it( %(<a href="#{url}">#{text.sub(/\/$/,'')}</a>), b+c ) + d
      end
    end
  end

  BRACKET_FORMATTERS = /[\+\-\^\*\?_@=~]/

  # linking using square brackets
  BRACKET_LINK_RE = /
    (^|.)         # start of line or any character $1
    \[(.)         # begin [ ($2 => first char)
    [ \t]*        # optional white space
    ([^\[\]]+)    # $text : one or more characters that are not [ or ] ($3)
    [ \t]*        # optional white space
    (.)\]         # end ] ($4 => last char)
  /x 

  def bracket_links( text ) 
    text.gsub!( BRACKET_LINK_RE ) do |m|
      all, preceding_char, first_char, text, last_char = $~[0..4]
      if preceding_char == '\\'
        all.sub('\\[', '[').sub('\\]', ']')
      elsif first_char == last_char and first_char =~ BRACKET_FORMATTERS
        all
      else
        text = first_char + text + last_char
        # text == "from -> to"
        from, to = text.split(/\s*->\s*/)[0..1]
        to ||= from
        if to =~ /^(\/|#{PROTOCOL}:\/\/)/
          # to == https://riseup.net
          # to == /an/absolute/path
          text = from.sub(/#{PROTOCOL}:\/\//, '').sub(/\/$/, '')
        else
          # to == "group_name / page_name"
          group_name, page_name = to.split(/[ ]*\/[ ]*/)[0..1]
          unless page_name
            # there was no group indicated, so $group_name is really the $page_name
            page_name = group_name
            group_name = @default_group
          end
          text = from =~ /\// ? page_name : from
          #atts = " href=\"/#{nameize group_name}/#{nameize page_name}\""
          to = '/%s/%s' % [nameize(group_name), nameize(page_name)]
        end
        if @block
          valid = @block.call(to)
        else
          valid = true
        end
        valid_class = valid ? '' : 'class="dead"'
        all = all.sub(/^#{Regexp.escape(preceding_char)}/,'')
        preceding_char + offtag_it('<a%s href="%s">%s</a>' % [valid_class,to,text], all)
      end
    end
  end

  ##
  ## EMBED
  ##

  EMBEDDED_RE = /(<embed .*><\/embed>|<object .*><\/object>)/

  ALLOWED_EMBEDDED_TAGS = {
    'object' => ['width', 'height'],
    'param' => ['name','value'],
    'embed' => ['src','type','width','height','allowscriptaccess', 'allowfullscreen']
  }.freeze

  def embedded( text )
    text.gsub!(EMBEDDED_RE) do |blk|
      offtag_it( formatter.clean_html($1, ALLOWED_EMBEDDED_TAGS) )
    end
  end
  
  ##
  ## UTILITY
  ##

  private
  
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

