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
require 'logger'
require File.dirname(__FILE__) + '/database.rb'
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
log = Logger.new(STDOUT)
log.level = Logger::DEBUG

db = Database.new(ARGV[0])
db.prepare_export_statements

file = File.open(ARGV[1], "w")

osm = Osm.new(db)

osm.find_way_where("k = 'highway' and v = 'footpath'")
#osm.find_segment_where("k = 'oneway' and v = 'Priory Close'")
#osm.find_way_from_segment
osm.find_segment_from_way
osm.find_node_from_segment
#osm.find_node_where("id = 28328008")

#update data from live server
#api = Api.new(osm, config, log)
#api.refresh_way

=begin
osm.way.each_value do |way|
    way.tags.each do |tag|
        if tag[0] == 'highway' && tag[1] == 'Pedestrian'
            tag[1] = 'pedestrian'
            way.action = 'modify'
        end
    end
end
=end

#write osm data
osm.to_xml(file)

puts "exported #{osm.node.length} nodes, #{osm.segment.length} segments and #{osm.way.length} ways"

file.close
db.close
