require 'rubygems'
require 'ruby-debug'
require 'yaml'
require 'test/unit'

test_dir =  File.dirname(File.expand_path(__FILE__))
require test_dir + '/../greencloth.rb'

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
    @markup_fixtures.each do |filename, docs|
      docs.each do |doc|
        assert_markup filename, doc, GreenCloth.new(doc['in']).to_html
      end
    end
  end

  def test_outline
    return unless @fixtures['outline.yml']
    @fixtures['outline.yml'].each do |doc|
      assert_markup('outline.yml', doc, GreenCloth.new(doc['in'], '', [:outline]).to_html)
    end
  end

  #def test_sections
  #  return unless @fixtures['sections.yml']
  #  @fixtures['sections.yml'].each do |doc|
  #    greencloth = GreenCloth.new( doc['in'] )
  #    greencloth.wrap_section_html = true
  #    assert_markup('sections.yml', doc, greencloth.to_html)
  #  end
  #end

  protected

  def assert_markup(filename, doc, html)
    in_markup = doc['in']
    out_markup = doc['out'] || doc['html']
    return unless in_markup and out_markup
    html.gsub!( /\n+/, "\n" )
    out_markup.gsub!( /\n+/, "\n" )
    if html == out_markup
      putc "."
    else
      puts "\n------- #{filename} failed -------"
      puts "---- IN ----"; p in_markup
      puts "---- OUT ----"; puts html
      puts "---- EXPECTED ----"; puts out_markup
      puts ""
    end
  end
end


