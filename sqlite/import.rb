#!/usr/bin/ruby

#imports planet file into sqlite db

#schema

#node
# id, lat, lon, user

require 'rexml/document'
require 'sqlite3'
require 'osm/sqlite/database.rb'
require 'osm/sqlite/xml.rb'

if ARGV.length != 2
    puts 'import.rb planet.osm database.db'
    exit
end

db = SQLite3::Database.new(ARGV[1])
create_tables(db)

db.execute("BEGIN")
listner = Listener.new(db)
osm = File.new ARGV[0]
REXML::Document.parse_stream(osm, listner)
db.execute("COMMIT")

osm.close
db.close
