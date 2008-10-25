#!/usr/bin/env ruby

require File.join(File.expand_path(File.dirname(__FILE__), 'greencloth'))
require 'yaml'

i = 0
files = ARGV[0] || Dir["tests/*.yml"]
files.each do |testfile|
  YAML::load_documents( File.open( testfile ) ) do |doc|
    next unless doc
    i += 1
    in_markup = doc['in']
    out_markup = doc['out'] || doc['html']
    if in_markup and out_markup
      html = GreenCloth.new( in_markup ).to_html      
      html.gsub!( /\n+/, "\n" )
      out_markup.gsub!( /\n+/, "\n" )
      if html == out_markup
        putc "."
      else
        puts "\n------- #{testfile} failed -------"
        puts "---- IN ----"; p in_markup
        puts "---- OUT ----"; puts html
        puts "---- EXPECTED ----"; puts out_markup
        puts ""
      end
    end
  end
  puts ""
end

