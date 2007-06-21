#!/usr/bin/env ruby

# $Id$

#imports planet file into sqlite db

require 'rexml/document'
require 'sqlite3'
require File.dirname(__FILE__) + '/database.rb'
require File.dirname(__FILE__) + '/xml_import.rb'

if ARGV.length != 2
    puts 'import.rb planet.osm database.db'
    puts 'To read planet.osm from stdin,'
    puts 'import.rb - database.db'
    exit
end

db = Database.new(ARGV[1])
puts 'creating tables'
db.create_tables()
db.prepare_import_statments()

db.db.execute("BEGIN")
listner = Listener.new(db)
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
