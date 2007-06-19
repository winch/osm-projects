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
osm.find_node_at([-1.3292029265489531,51.79098143963174,-1.1006619594647056,52.012704057421765])
osm.find_segment_from_node


#write osm data
output.write(osm)

puts "exported #{osm.node.length} nodes, #{osm.segment.length} segments and #{osm.way.length} ways"

output.close
file.close
db.close
