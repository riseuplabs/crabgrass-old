
# http://css3pie.com/

=begin

the theme code does a good job of figuring out if a value, when rendered as css,
should have quotes around it or not. you can force it to not have quotes by
creating a symbol, like so...
 
  masthead {
    height :"100px"
  }

In this case, this is not needed, because values in px units are not quoted by
default anyway.

you are not allowed to know selectors of css or structure of html. this might change, so don't rely on it.

'html' is a special options. it takes either a string, a hash, or a block. 
 * string: inserts this value directly into the template
 * hash: the template will call render and pass in the hash.
 * block: this will get eval'ed in the context of the view.

'css' is a special option. it will get included in the stylesheet as a sass mixin. 
this means you can make sass calls (using scss format).

=end

$border = '1px solid #ccc'

options {

  favicon_png 'favicon.png'
  favicon_ico 'favicon.ico'

  grid {
    column {
      width '40px'
      count 16
      gutter '15px'
      side_gutter '15px'
    }
    font {
      size '16px'
      line_height '24px'
    }
  }

  # general color constants that are frequently reused
  color {
    dim '#999';
    bright '#f33';
  }

  font {
    heading {
      family :"sans-serif";
      h1_size "2.10em";
      h2_size "1.125em";
      h3_size "1em";
      h4_size "1em";
    }
  }

  background {
    color '#e6e6e6';
  }

  masthead {
    style 'full'   # accepts [full | grid]
                   # full -- the masthead stretches the full width of the screen
                   # grid -- the masthead stops at the edge of the grid.
    border $border # not yet supported
    height '100px'
    css "background-color: #f9f9f9;"
#    css %{
#      @include linear-gradient(color-stops(green, red));
#    }
    content {
      vertical_align 'center' # accepts [center | top]
                              # if you set center alignment, you are still
                              # responsible for aligning whatever text you put
                              # in the content block.
      height "2.5em"          # required if vertical_align == 'center'
      padding var(:grid_column_gutter)
      html { content_tag :div, current_site.title, :id => 'masthead_title' }
    }
    nav {
      style 'cutout'  # accepts [cutout | bar]
                     # cutout -- creates tabs cut out from masthead
                     # bar -- creates a separate menu nav bar
      tab {
        padding '8px'   # must be in pixels
        css %{ }
        active_css %{   }
      }
      dropdown {
        background_color 'white'
        border_color '#999'
        hover {
          background_color '#ffc';
          border '1px solid #cc9';
        }
      }
    }
  }

  global_nav {
  }

  banner {
    # unfortunately, banner padding must be specified in pixels.
    padding "12px"
    border "1px solid #888"
    default_background '#999'
    default_foreground '#fff'
    vertical_align 'default'  # [center | top | default]
    font {
      size "36px" # var(:font_heading_h1_size)
    }
    nav {
      style 'cutout' # [cutout | inset | none]
      padding '6px'
    }
  }

  local {
    # border $border
    content {
      border $border
      background 'white'
    }
    nav {
      style 'tabs'
      side 'left'   # only left for now.
      column_count 3
    }
  }

  # all the various z-index values are defined here. 
  # these should not ever need to be changed. 
  zindex {
    menu 99            # masthead navigation menus
    tooltip 300        #
    autocomplete 400   # autocomplete popups


  }

}

style %{
  #masthead_title {
    color: #333;
    font-size: 1.5em;
    // vertically center align:
    line-height: 1.5em;
  }
}

=begin
masthead {
  nav {}
}
error {}
banner {
  nav { }
}
page {
  sidebar {  }
  titlebox {  }
  comments {  }
}
landing {
  sidebar {  }
}
footer {}
type {}
colors {}
grid {}
=end

=begin
##
## BAD OLD STUFF
##


  ##
  ## general colors
  ##

    link_color "#998675"
    almost_black "#534741"
    warm_grey_text "#998675"
    warm_grey_border "#b89882"
    warm_grey_block "#b89882"
    light_grey_text "#7d7d7d"
    light_grey_border "#ddd"
    lighter_grey_text "#aaa"
    medium_grey_text "#707070"
    medium_grey_border "#bbb"
    blue "#4978bc"
    red "#bd5743"

    posts_bg "#fff"
    footer_bg "#fff"

    general_bg "#E6E3DC"
    content_bg "#fff"

  ##
  ## MASTHEAD
  ##

#"#000000 url(/riseup-masthead.png) 0 0 no-repeat"
  masthead_header_text "#fff"
  masthead_search_text "#fff"

  ##
  ## GLOBAL NAV
  ##

  global_nav_dropdown_bg "#fff"
  global_nav_top_brdr "#a6c0cb"
  global_nav_btm_brdr "#a6c0cb"
  global_nav_bg "#fff"
  global_nav_text "#4978bc"

  ##
  ## BANNER
  ##

  banner_bg "#eef5fc"
  banner_title "#464646"
  banner_button "#78be63"
  banner_brdr_btm "#a6c0cb"

  second_nav_border "#dbdbdb"
  second_nav_bg "#fff"
  second_nav_current "#4978bc"
  second_nav_link "#aaa"

  third_nav_border "#ebebeb"
  third_nav_bg "#fff"
  third_nav_text "#aaa"
  third_nav_current "#4978bc"

  ##
  ## PAGE
  ##

  page_title_bg "#eef5fc"
  page_title_color "#bd5743"
  page_title_h3 "20px"
  page_title_tabs_bg "#eef5fc"
  page_title_tabs_text "#4978bc"

  ##
  ## TYPOGRAPHY
  ##

  headings_font "arial, helvetica, sans-serif"
  general_font "verdana, bitstream vera sans, helvetica, sans-serif"

  h1_size "22px"
  h2_size "18px"
  h3_size "16px"
  h4_size "13px"
  h5_size "11px"
  h6_size "9px"
  h1_color "#534741"
  h2_color "#534741"
  h3_color "#bd5743"
  h4_color "#777"

  ##
  ## OTHER
  ##

  menu_border_color "#000"
  popup_bg "#f3f2ee"
  box1_bg_color "#eee"
  notification "#ffffcc"
=end

