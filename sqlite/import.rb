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

require 'rexml/document'
require 'sqlite3'
require File.dirname(__FILE__) + '/database.rb'
require File.dirname(__FILE__) + '/xml_import.rb'
require File.dirname(__FILE__) + '/xml_reader.rb'

if ARGV.length != 2
    puts 'import.rb planet.osm database.db'
    puts 'To read planet.osm from stdin,'
    puts 'import.rb - database.db'
    exit
end

db = Database.new(ARGV[1])
puts 'creating tables'
db.create_tables()
db.prepare_import_statements()

db.db.execute("BEGIN")

importer = Xml_import_database.new(db)

listner = Listener.new(importer)
if (ARGV[0] == '-')
    osm = STDIN
else
    osm = File.new ARGV[0]
end

puts 'importing'
REXML::Document.parse_stream(osm, listner)
puts 'indexing'
db.create_index()
db.db.execute("COMMIT")

osm.close
db.close

puts 'import finished'
