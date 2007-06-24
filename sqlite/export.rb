#!/usr/bin/env ruby

#--
# $Id$
#
#Copyright (C) 2007 David Dent
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

require 'sqlite3'
require File.dirname(__FILE__) + '/database.rb'
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

puts 'find_way_where'
#osm.find_way_where("k = 'area' and v = 'yes'")
osm.find_segment_where("k = 'class' and v = 'canal'")
osm.find_way_from_segment
puts 'find segment from way'
osm.find_segment_from_way
puts 'find node from segment'
osm.find_node_from_segment

#update data from live server
#api = Api.new(osm, config)
#api.refresh_way

=begin
osm.way.each_value do |way|
    action = nil
    way.tags.each do |tags|
        if tags[0] == 'highway' and tags[1] = 'footpath'
            tags[1] = 'footway'
            action = 'modify'
        end
    end
    way.action = action
end
=end

#write osm data
output.write(osm)

puts "exported #{osm.node.length} nodes, #{osm.segment.length} segments and #{osm.way.length} ways"

output.close
file.close
db.close
