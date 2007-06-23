#!/usr/bin/env ruby

# $Id$

#responds to api requests, currently only bbox requests

require 'sqlite3'
require 'stringio'
require 'thread'
require 'webrick'
include WEBrick
require File.dirname(__FILE__) + '/xml_write.rb'
require File.dirname(__FILE__) + '/database.rb'
require File.dirname(__FILE__) + '/osm.rb'

$VERSION = '0.1'
$API_VERSION = '0.4'

if ARGV.length != 2
    puts 'server.rb port database.db'
    exit
end

class MapServlet < HTTPServlet::AbstractServlet

    attr_reader :instance
    @@instance = nil
    @@mutex = Mutex.new

    def self.get_instance(config, *options)
        @@mutex.synchronize do
            @@instance = @@instance || self.new(config, *options)
        end
    end

    def initialize(config, database)
        super
        @db = Database.new(database)
        @db.prepare_export_statments
    end

    def close
        @db.close
    end

    def do_GET(req, res)
        if req.query['bbox']
            bbox = req.query['bbox'].split(',')
            if bbox.length != 4
                raise HTTPStatus::PreconditionFailed.new("badly formatted attribute: 'bbox'")
            end
            res['Content-Type'] = 'Content-Type: text/xml; charset=utf-8'
            osm = Osm.new(@db)
            output = StringIO.new
            xml = Xml_writer.new(output)
            @logger.info('find_node_at | ' + req.query['bbox'])
            osm.find_node_at(bbox)
            @logger.info('find_segment_from_node')
            osm.find_segment_from_node
            @logger.info('find_way_from_segment')
            osm.find_way_from_segment
            @logger.info('find_segment_from_way')
            osm.find_segment_from_way
            @logger.info('find_node_from_segment')
            osm.find_node_from_segment
            @logger.info("exported #{osm.node.length} nodes, #{osm.segment.length} segments and #{osm.way.length} ways")
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

server = HTTPServer.new(:Port => ARGV[0].to_i)
server.mount('/api/' + $API_VERSION + '/map', MapServlet, ARGV[1])

trap ("INT") do
    server.shutdown
    MapServlet.instance.close if !MapServlet.instance.close.nil?
end

server.start
