#!/usr/bin/env ruby

#--
# $Id$

$VERSION = '0.1'
$API_VERSION = '0.5'

require 'sqlite3'

if ARGV.length != 2
    puts 'planet.rb database.db output.osm'
    exit
end

db = SQLite3::Database.new(ARGV[0])

File.open(ARGV[1], 'w') do |file|
    file.puts('<?xml version="1.0" encoding="UTF-8"?>')
    file.puts("<osm version='#{$API_VERSION}' generator='planet v#{$VERSION}'>")
    
    #nodes
    db.execute('SELECT id, lat, lon FROM node') do |node|
        file.write("  <node id='#{node[0]}' lat='#{node[1]}' lon='#{node[2]}'")
        tags = ''
        db.execute('SELECT tag.k, tag.v FROM node_tag INNER JOIN tag ON node_tag.tag = tag.id WHERE node_tag.node = ?', node[0]) do |tag|
            tags << "    <tag k='#{tag[0]}' v='#{tag[1]}'/>\n"
        end
        
        if tags == ''
            file.puts('/>')
        else
            file.puts('>')
            file.puts(tags)
            file.puts('  </node>')
        end
    end
    
    #ways
    db.execute('SELECT id FROM WAY') do |way|
        file.puts("  <way id='#{way[0]}'>")
        
        #nodes
        db.execute('SELECT node FROM way_node WHERE way = ? ORDER BY position', way[0]) do |way_node|
            file.puts("    <nd ref='#{way_node[0]}'/>")
        end
        
        #tags
        db.execute('SELECT tag.k, tag.v FROM way_tag INNER JOIN tag ON way_tag.tag = tag.id WHERE way_tag.way = ?', way[0]) do |tag|
            file.puts("    <tag k='#{tag[0]}' v='#{tag[1]}'/>")
        end
        
        file.puts('  </way>')
    end
    
    file.puts('</osm>')
end

