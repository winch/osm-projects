#!/usr/bin/env ruby

#--
# $Id$

$VERSION = '0.1'
$API_VERSION = '0.5'

require 'sqlite3'
require 'rexml/document'

require File.dirname(__FILE__) + '/xml_listener.rb'
require File.dirname(__FILE__) + '/primative.rb'
require File.dirname(__FILE__) + '/query.rb'
require File.dirname(__FILE__) + '/query_node.rb'
require File.dirname(__FILE__) + '/query_way.rb'
require File.dirname(__FILE__) + '/database.rb'
require File.dirname(__FILE__) + '/database_node.rb'
require File.dirname(__FILE__) + '/database_way.rb'
require File.dirname(__FILE__) + '/database_map.rb'

if ARGV.length != 2
    puts 'inport.rb database.db import.osm'
    exit
end

db = DatabaseMap.new(ARGV[0])
db.create_tables
db.db.execute("BEGIN")

#hash mapping node id in file to node id in database
new_node = Hash.new

node_c = 1
way_c = 1       

found = Proc.new do |primative|
    if primative.class == Node
        new_node[primative.id] = db.insert_node(primative.lat, primative.lon)
        #insert tags
        primative.tags.each do |tag|
            db.insert_node_tag(new_node[primative.id], tag)
        end
        node_c += 1
    end
    if primative.class == Way
        #replace node ids from file with node ids in database
        primative.nodes.collect! do |id|
            id = new_node[id]
        end
        primative.id = db.insert_way(nil, primative.nodes)
        primative.tags.each do |tag|
            db.insert_way_tag(primative.id, tag)
        end
        way_c += 1
    end
    if primative.class == Relation
        #TODO
    end
    if node_c % 10000 == 0
        puts "#{node_c} nodes"
    end
    if way_c % 10000 == 0
        puts "#{way_c} ways"
    end
end

File.open(ARGV[1]) do |file|
    #parse xml
    listner = XMLListener.new(nil, found)
    REXML::Document.parse_stream(file, listner)
    #node = listner.primative   
end

db.db.execute("COMMIT")
db.create_index
db.close

