#!/usr/bin/ruby

# $Id$

#responds to api requests, currently only bbox requests

require 'sqlite3'
require 'webrick'
include WEBrick

$VERSION = '0.1'

if ARGV.length != 2
    puts 'server.rb port database.db'
    exit
end

class MapServlet < HTTPServlet::AbstractServlet
    def do_GET(req, res)
        #
    end
end

server = HTTPServer.new(:Port => ARGV[0].to_i, :DocumentRoot => '/home/david/')

trap ("INT") { server.shutdown }

server.start
