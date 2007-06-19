#!/usr/bin/env ruby

# $Id$

#exports from db to osm xml

require 'sqlite3'
require File.dirname(__FILE__) + '/database.rb'
require File.dirname(__FILE__) + '/primative.rb'
require File.dirname(__FILE__) + '/xml_write.rb'
require File.dirname(__FILE__) + '/osm.rb'

$VERSION = '0.1'

if ARGV.length != 2
    puts 'export.rb database.db output.osm'
    exit
end

db = Database.new(ARGV[0])
db.prepare_export_statments
file = File.open(ARGV[1], "w")
output = Xml_writer.new(file)

osm = Osm.new(db)

#osm.find_way_where("k = 'name' and v = 'Oxford Canal'")
#osm.find_segment_from_way
#osm.find_node_from_segment
puts 'find_node_at'
osm.find_node_at([-1.1499991596049273,51.88416634514814,-1.1363962754509815,51.897363397399154])
puts 'find_segment_from_node'
osm.find_segment_from_node
puts 'find_way_from_segment'
osm.find_way_from_segment
puts 'find_segment_from_way'
osm.find_segment_from_way


#write osm data
output.write(osm)

puts "exported #{osm.node.length} nodes, #{osm.segment.length} segments and #{osm.way.length} ways"

output.close
file.close
db.close
