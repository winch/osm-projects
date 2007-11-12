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
require 'stringio'
require 'thread'
require 'webrick'
include WEBrick
require File.dirname(__FILE__) + '/database.rb'
require File.dirname(__FILE__) + '/osm.rb'

$VERSION = '0.1'
$API_VERSION = '0.5'

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
        @db.prepare_export_statements
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
            @logger.info('find_node_at | ' + req.query['bbox'])
            osm.find_node_at(bbox)
            @logger.info('find way from node')
            osm.find_way_from_node
            @logger.info('find node from way')
            osm.find_node_from_way
            @logger.info('generating xml')
            osm.to_xml(output)
            output.rewind
            res.body = output.read
            output.close
            @logger.info("exported #{osm.node.length} nodes, #{osm.segment.length} segments and #{osm.way.length} ways")
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
