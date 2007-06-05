#!/usr/bin/ruby

#imports planet file into sqlite db

require 'sqlite3'
require 'osm/sqlite/primative.rb'
require 'osm/sqlite/xml_write.rb'
require 'osm/sqlite/find.rb'

if ARGV.length != 2
    puts 'export.rb database.db output.osm'
    exit
end

db = SQLite3::Database.new(ARGV[0])
output = File.open(ARGV[1], "w")
output.write('<?xml version="1.0" encoding="UTF-8"?>' + "\n")
output.write('<osm version="0.4" generator="export.rb">' + "\n")

osm_node = Hash.new
osm_segment = Hash.new
osm_way = Hash.new
way_count = 0

Find.find_way(db, osm_way, "v = 'Windmill Avenue'")
Find.find_segment(db, osm_way, osm_segment)
Find.find_node(db, osm_segment, osm_node)

#write osm data

#node
osm_node.each do |id, node|
    Xml.write_node(output, id, node)
end

#segment
osm_segment.each do |id, segment|
    Xml.write_segment(output, id, segment)
end

#way
osm_way.each do |id, way|
    Xml.write_way(output, id, way)
    way_count += 1
end

puts "exported #{way_count} way(s)"

output.write("</osm>\n")
output.close
db.close
