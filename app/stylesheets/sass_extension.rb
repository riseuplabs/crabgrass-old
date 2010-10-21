# define here new extensions you want available in sass 
# stylesheets.

module Sass::Script::Functions
  # takes a border string, like '1px solid green'
  # and returns 1px
  def border_size(string)
    Sass::Script::Number.new( string.to_s.split(' ').first.to_i, ['px'])
  end

  def border_color(string)
    assert_type string, :String
    Sass::Script::String.new(string.to_s.split(' ').last)
  end
  
end


