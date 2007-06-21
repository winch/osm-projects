#!/usr/bin/env ruby

# $Id$

#exports from db to osm xml

require 'sqlite3'
require File.dirname(__FILE__) + '/database.rb'
require File.dirname(__FILE__) + '/primative.rb'
require File.dirname(__FILE__) + '/xml_write.rb'
require File.dirname(__FILE__) + '/osm.rb'
require File.dirname(__FILE__) + '/config.rb'
require File.dirname(__FILE__) + '/api.rb'
require File.dirname(__FILE__) + '/xml_import.rb'
require File.dirname(__FILE__) + '/xml_reader.rb'

$VERSION = '0.1'

if ARGV.length != 2
    puts 'export.rb database.db output.osm'
    exit
end

config = Config.load(File.dirname(__FILE__) + '/config.yaml')

db = Database.new(ARGV[0])
db.prepare_export_statments

file = File.open(ARGV[1], "w")
output = Xml_writer.new(file)

osm = Osm.new(db)

osm.find_way_where("k = 'Highway'")
osm.find_segment_from_way
osm.find_node_from_segment

#update data from live server
api = Api.new(osm, config)
api.refresh_way

#write osm data
output.write(osm)

puts "exported #{osm.node.length} nodes, #{osm.segment.length} segments and #{osm.way.length} ways"

output.close
file.close
db.close
