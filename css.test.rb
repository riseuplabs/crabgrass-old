require 'rubygems'
gem 'casuistry'
require 'casuistry'

#
# parkaby makes markaby much much faster
#

css = Casuistry.new

css.process do
  div do

    # this is a property on div
    background :red

    selector('ul li') do
      color('green')
    end

    selector('ul li') do
      color('red')
    end

    p.ugly.truly do
      color('aqua')
    end

    selector('.smurf').house do
      height('256px')
    end

    menu! do
      padding("10px")
    end

    # this is a property on div, again
    width('9934px')

  end

  gargamel do
    margin("0px")
  end

  selector('.outer.middle.inner') do
    top("34px")
  end
end

def fancy_border(arg)
  puts arg.inspect
end

css.process do
  ['a', 'b', 'c'].each do |i|
    selector('li.'+i) do
      color i
    end
  end
end

p css.data    #=> array of arrays

puts css.output  #=> string of css


namespace tree structure
contents of tree:
  flags / settings
  images
  css
  html snippets
duplicate a tree and selectively override parts


head
masthead
  topnav
banner

content
  article
  aside

page < content
  titlebox
    infobox
  article
  aside
  comments

landing
  

profile
  

me < content
  

footer


name 'page > content > wiki' do

  css('.wiki, .post') do

    set :heading do
      margin-bottom: 8px
      margin-top: 12px
    end

    h1(:heading) do
      font-size '10px'
    end

  end

end

name 'page' do
  name 'titlebox' do
    color :red
    css do
    end
  end
end

