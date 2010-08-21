path = File.dirname(__FILE__)
require File.expand_path(path + "/test_helper")
require 'ruby-debug'
require 'yaml'
require 'greencloth'

test_dir =  File.dirname(File.expand_path(__FILE__))

SINGLE_FILE_OVERRIDE = if ARGV[0] and ARGV[0] !~ /\.rb/
  ARGV[0]
else
  nil
end

class TestMarkup < Test::Unit::TestCase

  def setup
    files = SINGLE_FILE_OVERRIDE || Dir[File.dirname(__FILE__) + "/fixtures/*.yml"]
    @fixtures = {}
    files.each do |testfile|
      YAML::load_documents( File.open( testfile ) ) do |doc|
        @fixtures[ File.basename(testfile) ] ||= []
        @fixtures[ File.basename(testfile) ] << doc
      end
    end
    @special = ['sections.yml', 'outline.yml']
    @markup_fixtures = @fixtures.reject{|key,value| @special.include? key}
  end

  def test_general_markup
    counter = Hash.new(0)
    @markup_fixtures.each do |filename, docs|
      print "\n#{filename}\t"
      docs.each do |doc|
        unless doc
          putc 'D'
          next
        end
        html = doc['html'] || doc['out']
        unless html
          putc '0'
          next
        end
        code = assert_greencloth filename, doc, Undress(html).to_greencloth
        counter[code] += 1
      end
    end
    puts
    puts counter.inspect
  end

  #def test_outline
  #  return unless @fixtures['outline.yml']
  #  @fixtures['outline.yml'].each do |doc|
  #    assert_greencloth('outline.yml', doc, GreenCloth.new(doc['in'], '', [:outline]).to_html)
  #  end
  #end

  #def test_sections
  #  return unless @fixtures['sections.yml']
  #  @fixtures['sections.yml'].each do |doc|
  #    greencloth = GreenCloth.new( doc['in'] )
  #    greencloth.wrap_section_html = true
  #    assert_markup('sections.yml', doc, greencloth.to_html)
  #  end
  #end

  protected

  def assert_greencloth(filename, doc, greencloth)
    in_greencloth = doc['in']
    in_markup = doc['html'] || doc['out']
    return unless in_greencloth and greencloth
    html = GreenCloth.new(greencloth, '').to_html
    html.gsub!( /\n+/, "\n" )
    in_markup.gsub!( /\n+/, "\n" )
    if greencloth.rstrip == in_greencloth.rstrip
      putc "."
      return :first
    elsif in_markup == html
      putc ":"
      return :second
    elsif in_markup.delete(' ') == html.delete(' ')
      putc "|"
      return :whitespace
    else
      # we are replacing some tags... let's see if this is what happened
      tags_changed = in_markup
      tags_changed.gsub! /<(\/?)b>/, '<\1strong>'
      tags_changed.gsub! /<(\/?)i>/, '<\1em>'
      if tags_changed == html
        putc "t"
        return :tags
      elsif tags_changed.delete(' ') == html.delete(' ')
        putc "T"
        return :tags_n_whitespace
      end

      putc "x"
      $stderr.puts "\n------- #{filename} failed -------"
      $stderr.puts "---- IN ----"; $stderr.puts in_markup
      $stderr.puts "---- OUT ----"; $stderr.puts greencloth
      $stderr.puts "---- EXPECTED ----"; $stderr.puts in_greencloth
      $stderr.puts "---- BACK TO HTML ----"; $stderr.puts html
      $stderr.puts ""
      return :fail
    end
  end
end


