#
# util.rb
# Utility and processing functions for GreenCloth
# 

require 'uri'
require 'zlib'
require "base64"
    
module Greencloth
module Util

  private

  # disable redcloth's broken hard breaks
  def hard_break( text )
  end
  
  def green_hard_break( text )
    # redcloth original:
    text.gsub!( /(.)\n(?!\Z| *([#*=]+(\s|$)|[{|]))/, "\\1<br />" )
    
    # reading this regexp:
    # (.)         any single character
    # \n          followed by a newline
    # (?!         look ahead to the next line and fail if...
    #   \Z        the line is empty
    #   |         or
    #    *        zero or more spaces
    #   (         followed by
    #     [#*=]+  one or more #*= characters
    #     (\s|$)  and whitespace or end of line
    #     |       or 
    #     [{|]    { or | character
    #   )
    # )           end of next line expression.
  end

  # escape "<" when it does not in the form of <pre> or <code> or
  # </pre> or </code> or <redpre# (the latter is used internally for
  # pre blocks that are removed from the text and then put back later.
  # 
  # TODO: bluecloth/markdown actually goes through the work of parsing the html
  # to find matching tags and raises an error if a tag is not properly closed.
  # If we wanted to allow some html, it seems like a good idea to do something
  # like that.
  #
  def escape_html( text )
    text.gsub!(/<(?!\/?(redpre#|pre|code))/, "&lt;" )
  end
  
  # makes it so that text is not filtered by any inline filters.
  # replaces the text with a placeholder, that is expanded at the end.  
  def bypass_filter( text )
    placeholder = "<redpre##{ @pre_list.length }>"
    @pre_list << text
    return placeholder
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

  def debug(msg)
    if msg.is_a? Hash
      msg = msg.inspect
    end
    puts "\n/---\n#{msg}\n\---\n"
  end

  def encode_and_compress_url_data(string)
    compressed = Zlib::Deflate.deflate(string, Zlib::BEST_SPEED)
    encoded = Base64.encode64(compressed)
    # we escape because encode64 puts in '\n' and '/' and '='
    # we turn each new line into a /, so that we can use page caching
    # (linux filename limit is 255, so we divide into directories)
    #return URI.escape(encoded, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    return encoded.strip.gsub('/','%7C').gsub('=','%3D').gsub("\n",'/')
  end

  def decode_and_expand_url_data(string)
    Zlib::Deflate.deflate( Base64.decode64(string) )
  end

  ######################################################
  # BLOCK PROCESSING
  #
  # The core redcloth function for block processing is blocks().
  # Unfortunately, we need to override this function, because
  # the redcloth version assumes that leading spacing in the block
  # means preformatted code. In order to change this behavior
  # we need our own blocks() function.
  #
  # So that I can understand what is going on, I have split the
  # behavior of blocks() into blocks() and process_single_block(). 
  # Some variable names have been changed to make the code more
  # readable (less inscrutable).
  #

  # Redcloth's block RE
  BLOCKS_GROUP_RE = /\n{2,}(?! )/m
      
  def blocks(text, indented = false, in_blockquote = false) 
    text.replace( 
      text.split( BLOCKS_GROUP_RE ).collect do |blk|
        process_single_block(blk, indented, in_blockquote)
      end.join("\n\n")
    )
  end
    
  def process_single_block(blk, indented, in_blockquote)
    blk.strip!
    return "" if blk.empty?

    #debug "process block #{indented} #{in_blockquote} \n/--\n#{blk}\n\\--"
    
    # process subsequent blocks that start with
    # a leading space. if the start of this block
    # was plain, then leading spaces make the subsequent
    # blocks into an indented block.
    started_as_plain = blk !~ /\A[#*> ]/
    skip_rules_blk = nil
    blk.gsub!( /((?:\n(?:\n^ +[^\n]*)+)+)/m ) do |iblk|
      iblk_indented = true if started_as_plain
      flush_left iblk
      blocks(iblk, iblk_indented)
      #iblk.gsub( /^(\S)/, "\t\\1" )
      if iblk_indented
        # don't apply block rules to indented blocks
        skip_rules_blk = iblk; ""
      else
        iblk
      end
    end
     
    # apply block rules
    block_applied = 0 
    @rules.each do |rule_name|
      block_applied += 1 if apply_block_rule(rule_name,blk)
    end
    
    # if no rules applied and indented, then output
    # a code block, otherwise we have a plain paragraph.
    if block_applied.zero?
      if indented
        #blk = "\t<pre><code>#{ blk }</code></pre>"
        blk = "<blockquote>#{ blk }</blockquote>"
      elsif !in_blockquote
        # apply hard breaks only to plain block where no
        # block rules have applied and we are not in
        # an explicit blockquote (ie lines starting >)
        green_hard_break(blk)
        blk = "<p>#{ blk }</p>"
      else
        blk = "<p>#{ blk }</p>"
      end
    end
    # add back in text of block that bypassed block rules.
    blk + "\n#{ skip_rules_blk }"
  end

  def apply_block_rule(rule_name, blk)
    rule_name.to_s.match /^block_/ and method( rule_name ).call( blk )
  end

  ##############################################
  ## OFFTAGS: when greencloth does not apply

  # changed from redcloth values
  OFFTAGS = /(code|pre)/
  OFFTAG_MATCH = /(?:(<\/#{ OFFTAGS }>)|(<#{ OFFTAGS }[^>]*>))(.*?)(<\/?#{ OFFTAGS }>|\Z)/mi

  # rip_offtags()
  # removes 'offtags' (code that turns off processes) from the text, 
  # and replaces it with <redpre01> or <redpre02>, etc.
  # the replaced text is stored in @pre_list.
  # later, the replaced text is returned via smooth_offtags
  # comments use example string "hi <code>there</code> bigbird!"
  
  def rip_offtags( text, inline=true )
    return text unless text =~ /<.*>/ # skip unless text has the possibility of tags
    text.gsub!( OFFTAG_MATCH ) do |line|
      matchtext  = $&  # eg '<code>there</code>'
      endisfirst = $1  # eg '</code>' (only if </code> appears before <code> in the text)
      tag        = $3  # eg '<code>'
      tagname    = $4  # eg 'code'
      codebody   = $5  # eg 'there'
      if tag and codebody
        htmlesc( codebody, :NoQuotes ) #if codebody
        if inline
          line = bypass_filter( format_inline_code(tag, codebody) )
        else
          line = bypass_filter( format_block_code(tag, codebody) )
        end
      end
      line
    end
    return text
  end

  def format_inline_code(tag,body)
    tag.match /<(#{ OFFTAGS })([^>]*)>/
    tagname, args = $1, $2
    "<#{tagname}>#{body}</#{tagname}>"
  end
  
  def format_block_code(tag, body)
    tag.match /<(#{ OFFTAGS })\s*([^>]*)\s*>/
    tagname, arg = $1, $3
    ret = "<#{tagname}>#{body.strip}</#{tagname}>"
    if tagname == 'code'
      ret = "<pre class=\"code\">#{ret}</pre>"
    end
    if arg.any?
      ret = "<div class=\"#{tagname}title\">#{arg}</div>\n#{ret}"
    end
    ret
  end

end
end

