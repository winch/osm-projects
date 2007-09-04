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
require 'rexml/document'

require File.dirname(__FILE__) + '/database.rb'
require File.dirname(__FILE__) + '/listener.rb'

if ARGV.length < 2
    puts 'import.rb database.db track.gpx'
    exit
end

db = Database.new(ARGV[0])
puts 'creating tables if required'
db.create_tables()
db.prepare_import_statments()

db.db.execute("BEGIN")

listener = Listener.new(db)

total_points = 0
points = 0
#import each gpx file ignoring ARGV[0]
ARGV[1..ARGV.length].each do |gpx|
    puts "importing #{gpx}"
    File.open(gpx) do |gpx_file|
        REXML::Document.parse_stream(gpx_file, listener)
    end
    puts "imported #{listener.count} points"
    total_points += listener.count
    listener.zero_count
end

puts "imported a total of #{total_points} points"

db.db.execute("COMMIT")
db.close
