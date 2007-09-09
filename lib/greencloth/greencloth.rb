require 'rubygems'
require 'redcloth'

# greencloth code:
$: << '..'
require 'greencloth/util'
require 'greencloth/inline'
require 'greencloth/block'

module Greencloth; end

class GreenCloth < RedCloth

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


  include Greencloth::Util
  include Greencloth::Inline
  include Greencloth::Block

  DEFAULT_RULES = [
    :block_crabgrass_code,
    :block_latex,
    :block_markdown_setext, 
    :block_textile_table,
    :block_textile_lists,
    :block_textile_prefix,
    :block_markdown_bq,
    :block_dictionary,
    :inline_crabgrass_link,
    :inline_auto_link_urls,
    :inline_textile_image,
    :inline_textile_code,
    :inline_textile_span,
    :glyphs_textile
  ]

  def initialize(string, default_group_name = 'page')
    @default_group = default_group_name
    super( string )
  end
  
  def to_html(*rules)
    green_html(DEFAULT_RULES)
  end
  
  # we have our own to_html method so that
  # we can insert escape_html exactly where
  # we need to in the procesessing.
  def green_html( *rules )
    rules = DEFAULT_RULES if rules.empty?
    # make our working copy
    text = self.dup
       
    @urlrefs = {}
    @shelf = []
    @rules = rules.collect do |rule|
      rule
    end.flatten

    # standard clean up
    incoming_entities text 
    clean_white_space text 

    # start processor
    @pre_list = []
    rip_offtags text, false
    #puts text
    #puts @pre_list.inspect
    escape_html text
    #no_textile text
    #hard_break text 
    unless @lite_mode
      refs text
      blocks text
    end
    inline text
    smooth_offtags text
    retrieve text

    #text.gsub!( /<\/?notextile>/, '' )
    text.gsub!( /x%x%/, '&#38;' ) # undo incoming_entities
    #clean_html text if filter_html
    text.strip!
    text
  end    
      
end

