#!/usr/bin/env ruby

#--
# $Id$
#
#Copyright (C) 2008 David Dent
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

# dumps all points in database to an .osm file
# each point is a node with a gpx = tp tag

require 'sqlite3'

$VERSION = '0.1'

if ARGV.length < 2
    puts 'dumposm.rb database.db output.osm'
    exit
end

db = SQLite3::Database.new(ARGV[0])
output = File.open(ARGV[1], "w")

#osm file header
output.puts('<?xml version="1.0" encoding="UTF-8"?>' + "\n")
output.puts("<osm version=\"0.5\" generator=\"dumposm.rb v#{$VERSION}\">\n")

#find all points
nodeId = 1
db.execute('select lat, lon from point') do |point|
    if nodeId % 100000 == 0
        puts "dumped #{nodeId} points"
    end
    output.puts("  <node id=\"#{nodeId}\" lat=\"#{point[0].to_f}\" lon=\"#{point[1].to_f}\">\n")
    output.puts("    <tag k=\"gpx\" v=\"tp\"/>\n")
    output.puts("  </node>\n")
    nodeId += 1
end

puts "dumped a total of #{nodeId} points"

#osm file footer
output.puts("</osm>\n")

db.close
output.close
