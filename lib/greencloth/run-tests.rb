#!/usr/bin/env ruby

#$: << '..'
require 'greencloth'
require 'yaml'

i = 0
files = ARGV[0] || Dir["tests/*.yml"]
files.each do |testfile|
  YAML::load_documents( File.open( testfile ) ) do |doc|
    next unless doc
    i += 1
    if doc['in'] and doc['out']
      green = GreenCloth.new( doc['in'] )
      html = green.to_html      
      html.gsub!( /\n+/, "\n" )
      doc['out'].gsub!( /\n+/, "\n" )
      if html == doc['out']
        putc "."
      else
        puts "\n------- #{testfile} failed -------"
        puts "---- IN ----"; p doc['in']
        puts "---- OUT ----"; p html
        puts "---- EXPECTED ----"; p doc['out']
        puts ""
      end
    end
  end
  puts ""
end

