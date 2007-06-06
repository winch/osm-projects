#!/usr/bin/ruby

#imports planet file into sqlite db

require 'sqlite3'
require 'osm/sqlite/primative.rb'
require 'osm/sqlite/xml_write.rb'
require 'osm/sqlite/find.rb'

$VERSION = '0.1'

if ARGV.length != 2
    puts 'export.rb database.db output.osm'
    exit
end

db = SQLite3::Database.new(ARGV[0])
output = Xml_writer.new(ARGV[1])

osm_node = Hash.new
osm_segment = Hash.new
osm_way = Hash.new

Find.find_way_where(db, osm_way, "v = 'Windmill Avenue'")
Find.find_segment_from_way(db, osm_way, osm_segment)
Find.find_node_from_segment(db, osm_segment, osm_node)
#Find.find_node_where(db, osm_node, "k like 'A%'")

#write osm data

#node
osm_node.each do |id, node|
    output.write_node(id, node)
end

#segment
osm_segment.each do |id, segment|
    output.write_segment(id, segment)
end

#way
osm_way.each do |id, way|
    output.write_way(id, way)
end

puts "exported #{osm_node.length} nodes, #{osm_segment.length} segments and #{osm_way.length} way(s)"

output.close()
db.close
