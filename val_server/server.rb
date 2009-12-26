#!/usr/bin/env ruby

$VERSION = '0.1'
$API_VERSION = '0.6'

if ARGV.length != 2
    puts 'server.rb port database.db'
    exit
end

require 'sqlite3'
require 'rexml/document'
require 'webrick'
include WEBrick

require File.dirname(__FILE__) + '/query.rb'
require File.dirname(__FILE__) + '/query_node.rb'
require File.dirname(__FILE__) + '/query_way.rb'
require File.dirname(__FILE__) + '/query_changeset.rb'
require File.dirname(__FILE__) + '/database.rb'
require File.dirname(__FILE__) + '/database_node.rb'
require File.dirname(__FILE__) + '/database_way.rb'
require File.dirname(__FILE__) + '/database_map.rb'
require File.dirname(__FILE__) + '/database_changeset.rb'
require File.dirname(__FILE__) + '/servlet_trackpoints.rb'
require File.dirname(__FILE__) + '/servlet_map.rb'
require File.dirname(__FILE__) + '/servlet_node.rb'
require File.dirname(__FILE__) + '/servlet_way.rb'
require File.dirname(__FILE__) + '/servlet_changeset.rb'
require File.dirname(__FILE__) + '/servlet_capabilities.rb'
require File.dirname(__FILE__) + '/xml_listener.rb'
require File.dirname(__FILE__) + '/primative.rb'

db = Database.new(ARGV[1])
db.create_tables
db.create_index
db.close

server = HTTPServer.new(:Port => ARGV[0].to_i)
server.mount("/api/#{$API_VERSION}/trackpoints", ServletTrackpoints, ARGV[1])
server.mount("/api/#{$API_VERSION}/map", ServletMap, ARGV[1])
server.mount("/api/#{$API_VERSION}/node", ServletNode, ARGV[1])
server.mount("/api/#{$API_VERSION}/way", ServletWay, ARGV[1])
server.mount("/api/#{$API_VERSION}/changeset", ServletChangeset, ARGV[1])
server.mount("/api/capabilities", ServletCapabilities)

trap ("INT") do
    server.shutdown
end

server.start


