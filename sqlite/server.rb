#!/usr/bin/env ruby

# $Id$

#responds to api requests, currently only bbox requests

require 'sqlite3'
require 'stringio'
require 'webrick'
include WEBrick
require File.dirname(__FILE__) + '/xml_write.rb'
require File.dirname(__FILE__) + '/primative.rb'
require File.dirname(__FILE__) + '/database.rb'
require File.dirname(__FILE__) + '/osm.rb'

$VERSION = '0.1'
$API_VERSION = '0.4'

if ARGV.length != 2
    puts 'server.rb port database.db'
    exit
end

class MapServlet < HTTPServlet::AbstractServlet
    def do_GET(req, res)
        if req.query['bbox']
            bbox = req.query['bbox'].split(',')
            if bbox.length != 4
                raise HTTPStatus::PreconditionFailed.new("badly formatted attribute: 'bbox'")
            end
            res['Content-Type'] = 'Content-Type: text/xml; charset=utf-8'
            osm = Osm.new($DB)
            output = StringIO.new
            xml = Xml_writer.new(output)
            osm.find_node_at(bbox)
            osm.find_segment_from_node
            osm.find_way_from_segment
            xml.write(osm)
            xml.close
            output.rewind
            res.body = output.read
            output.close
            raise HTTPStatus::OK
        else
            raise HTTPStatus::PreconditionFailed.new("missing attribute: 'bbox'")
        end
    end
end

$DB = Database.new(ARGV[1])
$DB.prepare_export_statments
server = HTTPServer.new(:Port => ARGV[0].to_i)
server.mount('/api/' + $API_VERSION + '/map', MapServlet)

trap ("INT") do
    server.shutdown
    $DB.close
end

server.start
