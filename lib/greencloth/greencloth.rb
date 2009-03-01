=begin

passing a block to to_html()
-----------------------------

  html = GreenCloth.new(test_text,'mygroup').to_html() do |link_data|
    process_link(link_data)
  end

  process_link should return either nil or an <a> tag. If nil, then
  the greencloth default is used.
  
  link_date is a hash that might include: url, label, context_name, page_name

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
  "<p>hello <code>}offtag#1{</code></p>"

=end

require 'rubygems'
begin
  # try redcloth 4.1
  gem 'redcloth', '>= 4.1'
  require 'redcloth'
rescue Exception
  # try redcloth 4.0
  gem 'RedCloth', '>= 4.0'
  require 'RedCloth'
end

require 'redcloth/formatters/html'
require 'cgi'

##
## GREENCLOTH HTML FORMATTER
##
## Our modifications to RedCloth take two forms: changes to the html formatter
## and changes to the TextileDoc. Here lie the changes to the formatter. For
## changes to TextileDoc, see below.
##

module GreenClothFormatterHTML
  include RedCloth::Formatters::HTML

  attr_reader :wiki_section_marked

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

  ##
  ## Allow some html, but not all
  ## (now handled by ALLOWED_TAGS)
  #ALLOWED_HTML_TAGS_RE = /<\/?(blockquote|em|strong|pre|code)>/
  #def inline_html(opts)
  #  if opts[:text] =~ ALLOWED_HTML_TAGS_RE
  #    "#{opts[:text]}" # nil-safe
  #  else
  #    html_esc(opts[:text], :html_escape_preformatted)    
  #  end
  #end

  ##
  ## convert "* hi:: there" --> "<li><b>hi:</b> there</li>"
  ##
  def li_open(opts)
    opts[:text].sub!(/^(.+):: /, '<b>\1:</b> ')
    "#{li_close unless opts.delete(:first)}#{"\t" * opts[:nest]}<li#{pba(opts)}>#{opts[:text]}"
  end

  def tr_open(opts)
    opts[:class] = [opts[:class], even_odd].compact.join(' ')
    "\t<tr#{pba(opts)}>\n"
  end

  def table_open(opts)
    @parity = 'even'
    super
  end

  def even_odd()
    @parity ||= 'even'
    @parity = @parity == 'odd' ? 'even' : 'odd'
    @parity
  end

  ## Most notably, we do not allow <script>, <div>, <textarea>, or <form>.
  ## These tags might really mess up the layout of the page or are a security
  ## risk. Also, unsafe attributes like 'onmouseover' are not allowed.
  ALLOWED_TAGS = {
    'a' => ['href', 'title'],
    'img' => ['src', 'alt', 'title'],
    'br' => [],
    'i' => nil,
    'u' => nil, 
    'b' => nil,
    'pre' => nil,
    'kbd' => nil,
    'code' => ['lang'],
    'cite' => nil,
    'strong' => nil,
    'em' => nil,
    'ins' => nil,
    'sup' => nil,
    'sub' => nil,
    'del' => nil,
    'table' => nil,
    'tr' => nil,
    'td' => ['colspan', 'rowspan'],
    'th' => nil,
    'ol' => ['start'],
    'ul' => nil,
    'li' => nil,
    'p' => ['class','style'],
    'span' => ['class','style'],
    'h1' => nil,
    'h2' => nil,
    'h3' => nil,
    'h4' => nil,
    'h5' => nil,
    'h6' => nil,
    'notextile' => nil, 
    'blockquote' => ['cite'],
    'object' => ['width', 'height'],
    'param' => ['name','value'],
    'embed' => ['src','type','width','height','allowscriptaccess', 'allowfullscreen']
  }

  def before_transform(text)
    clean_html(text, ALLOWED_TAGS) if sanitize_html # (sanitize_html should always be true)
  end

end


##
## GREENCLOTH PARSER
##
## Our modifications to RedCloth take two forms: changes to the html formatter
## and changes to the TextileDoc. Here lie the changes to the TextileDoc. For
## changes to formatter, see above.
##

class GreenCloth < RedCloth::TextileDoc
  include GreenClothTextSections

  attr_accessor :original
  attr_accessor :offtags
  attr_accessor :formatter
  attr_accessor :wrap_section_html

  def initialize(string, default_group_name = 'page', restrictions = [])
    @default_group = default_group_name
    restrictions.each { |r| method("#{r}=").call( true ) }

    # filter_ids    -- don't allow the user to set dom ids in the markup. This can
    #                  royally mess with the display of a page.
    # sanitize_html -- allows some basic html, see ALLOWED_TAGS aboved.
    super(string, [:filter_ids, :sanitize_html])
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

    section_start_re = Regexp.union(GreenCloth::TEXTILE_HEADING_RE, GreenCloth::HEADINGS_RE)

    before_filters += [:delete_leading_whitespace, :normalize_code_blocks, :offtag_obvious_code_blocks,
      :bracket_links, :auto_links, :headings, :quoted_block,
      :tables_with_tabs, :wrap_long_words]

    formatter = self.clone()                   # \  in case one of the before filters
    formatter.extend(GreenClothFormatterHTML)  # /  needs the formatter.

    apply_rules(before_filters)
    html = to(GreenClothFormatterHTML)
    html = add_wiki_section_divs(html) if wrap_section_html

    extract_offtags(html)

    # mark off
    return html
  end

  def apply_inline_filters(text)
    bracket_links(text)
    auto_links(text)
    text
  end

  ##
  ## CODE
  ##

  # sometimes we like exactly what RedCloth does, but we would like to change
  # the syntax slightly. In these cases, we simply modify the source text to
  # replace the greencloth markup with the equivelent redcloth markup before
  # any other processing is done.
  
  TEXTILE_HEADING_RE = /^h[123]\./

  # allow setext style headings
  HEADINGS_RE = /^(.+?)\r?\n([=-])[=-]+ */
  def headings(text)
    text.gsub!(HEADINGS_RE) do
      tag = $2=="=" ? "h1" : "h2"
      "#{ tag }. #{$1}\n\n"
    end
  end
  
  def delete_leading_whitespace(text)
    self.sub!(/\A\s*/, '')
  end

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
      tag.gsub!(/<(.+)? (.*)>/,'<\\1>') # prevent <code onmouseover='something nasty'>
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

  TABLE_TABS_RE = /^\t.*\t(\r?\n|$)/
  def tables_with_tabs( text )
    text.gsub!( TABLE_TABS_RE ) do |row|
      row.gsub /\t/, '|'
    end
  end

  ##
  ## OFFTAGS
  ##

  OFFTAG_PREFIX = 'offtag'
  OFFTAG_RE = /\}#{OFFTAG_PREFIX}#([\d]+)\{/  # matches }offtag#55{ -> $1 == 55
                                              # why }{ instead of {}? so offtags will work with tables.

  # text: the text to offtag
  # original: the original raw text before transformation. we keep it in case
  #           we need to undo the offtagging for a particular block.
  def offtag_it(text, original='')
    @count ||= 0
    @offtags ||= []
    @count += 1
    @offtags << [text, original]
    '}offtag#%s{' % @count
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
    (\1|\r?\n|$|[#{URL_PUNCT}](\s|\r?\n|$))  #(d) TRAILING TEXT
  }x

  def auto_links(text)
    text.gsub!(AUTO_LINK_RE) do
      all, a, b, c, d = $&, $1, $2, $3, $4
      if a =~ /<a\s/i # don't replace URL's that are already linked
        all
      elsif c.nil?
        all
      else
        first_char = a[0..0]
        if first_char =~ BRACKET_FORMATTERS and (first_char == c[-1..-1])
          # match formatting characters and don't autolink them if the same one exists on both sides
          d = first_char
          c.chop! # remove last char from c.
        end
        label = c
        url = %(#{b=="www."?"http://www.":b}#{c})
        link = nil
        if @block
          link = @block.call(:auto => true, :url => url)
        end
        unless link
          text = truncate(label, 42).sub(/\/$/,'')
          link = '<a href="%s">%s</a>' % [url, self.formatter.html_esc(text)]
        end
        a + offtag_it(link, b+c ) + d
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
      begin
        all, preceding_char, first_char, link_text, last_char = $~[0..4]
        if preceding_char == '\\'
          # the bracket is escaped and so we should ignore
          all.sub('\\[', '[').sub('\\]', ']')
        elsif first_char == '#' and last_char == '#'
          # make this a named anchor tag, instead of a link
          label, anchor = link_text.split(/\s*->\s*/)[0..1]
          anchor ||= label
          a_tag = '<a name="%s">%s</a>' % [anchor.nameize, htmlesc(label.strip)]
          all = all.sub(/^#{Regexp.escape(preceding_char)}/,'')
          preceding_char + offtag_it(a_tag, all)
        elsif first_char == last_char and first_char =~ BRACKET_FORMATTERS
          # the brackets are for wiki formatting, not links
          all
        else
          # we got an actual bracket style link!
          a_tag = nil # the eventual <a> tag
          link_text = first_char + link_text + last_char
          if link_text =~ /^.+\s*->\s*.+$/
            # link_text == "from -> to"
            from, to = link_text.split(/\s*->\s*/)[0..1]
            from = "" unless from.instance_of? String # \ sanity check for 
            to   = "" unless from.instance_of? String # / badly formed links
          else
            # link_text == "to" (ie, no link label)
            from = nil
            to = link_text
          end
          if to =~ /^(\/|#{PROTOCOL}:\/\/)/
            # the link is a fully formed url or an absolute path, eg: 
            # to == https://riseup.net
            # to == /an/absolute/path
            from ||= to.gsub(/(^#{PROTOCOL}:\/\/|^\/|\/$)/, '')
          else
            # the link is a wiki style link, eg
            # to == "context_name / page_name"
            # to == "page_name"
            context_name, page_name = to.split(/[ ]*\/[ ]*/)[0..1]
            unless page_name
              # there was no context indicated, so context_name is really the page_name
              page_name = context_name
              context_name = nil
            end
            if page_name =~ /#/
              # handle link to anchor
              if page_name =~ /^#/
                # relative anchor on this page
                page_name = page_name[1..-1] # chomp first char
                from ||= page_name.denameize
                a_tag = '<a href="#%s">%s</a>' % [page_name.nameize, htmlesc(from)]
              else
                page_name = page_name.sub(/#(.*)$/, '')
                anchor = '#' + $1.nameize if $1  # everything after the # in the link.
              end
            else
              anchor = ''
            end
            if @block and a_tag.nil?
              a_tag = @block.call(:label => from, :context => context_name, :page => page_name, :anchor => anchor)
            end
            unless a_tag
              from ||= page_name.nameized? ? page_name.denameize : page_name
              context_name ||= @default_group
              to = '/%s/%s%s' % [context_name.nameize, page_name.nameize, anchor]
            end
          end
          a_tag ||= '<a href="%s">%s</a>' % [htmlesc(to), htmlesc(from)]
          all = all.sub(/^#{Regexp.escape(preceding_char)}/,'')
          preceding_char + offtag_it(a_tag, all)
        end
      rescue Exception => exc
        # something horribly wrong has happened
        a_tag = '<a href="%s">%s</a>' % ["#error",from]
        #comment = '<!-- %s -->' % exc.to_s
        preceding_char + offtag_it(a_tag, all)
      end
    end
  end

  ##
  ## WRAP LONG WORDS
  ## really long words totally mess up most layouts.
  ## so here we break them up with some special spans.
  ## 

  # this style is required to make this look right:
  # span.break {font-size:1px;line-height:1px;float:right !important;float:none;}
  # this tries to make the span invisible in as many browsers as possible.

  LONG_WORD_CHAR_MAX = 30
  LONG_WORDS_RE = /(\w{#{LONG_WORD_CHAR_MAX},})/
  def wrap_long_words(text)
    # <wbr/> is a soft wrap tag, noting where a break may occur.
    # unfortunately, it is not supported in all browsers.
    text.gsub!(LONG_WORDS_RE) do |word|
      chopped = word.scan(/.{#{LONG_WORD_CHAR_MAX}}/)
      offtag = offtag_it("<wbr/><span class='break'> </span>")
      remainder = word.split(/.{#{LONG_WORD_CHAR_MAX}}/).select{|str| str.any?}
      (chopped + remainder).join(offtag)
    end
  end

  ##
  ## EMBED
  ##

  #EMBEDDED_RE = /(<embed .*><\/embed>|<object .*><\/object>)/

  #ALLOWED_EMBEDDED_TAGS = {
  #  'object' => ['width', 'height'],
  #  'param' => ['name','value'],
  #  'embed' => ['src','type','width','height','allowscriptaccess', 'allowfullscreen']
  #}.freeze

  #def embedded( text )
  #  text.gsub!(EMBEDDED_RE) do |blk|
  #    offtag_it( formatter.clean_html($1, ALLOWED_EMBEDDED_TAGS) )
  #  end
  #end
  
  ##
  ## UTILITY
  ##

  private
  
  # from actionview texthelper
  def truncate(text, length = 30, truncate_string = "...")
    if text.nil? then return end
    l = length - truncate_string.length
    text.length > length ? text[0...l] + truncate_string : text
  end

  def htmlesc(string)
    self.formatter.html_esc(string)
  end

end

##
## CORE STRING EXTENSIONS
##

unless "".respond_to? 'nameize'

  require 'iconv'
  class String
    def nameize
      str = self.dup
      str.gsub!(/[^\w\+]+/, ' ') # all non-word chars to spaces
      str.strip!            # ohh la la
      str.downcase!         # upper case characters in urls are confusing
      str.gsub!(/\ +/, '-') # spaces to dashes, preferred separator char everywhere
      #str = "#{str}" if str =~ /^(\d+)$/ # don't allow all numbers
      return str[0..49]
    end
    def denameize
      self.gsub('-',' ')
    end
    # returns false if any char is detected that is not allowed in
    # 'nameized' strings
    def nameized?
      self == self.nameize
    end
  end

end
