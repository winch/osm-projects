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

require 'net/http'
require 'uri'
require 'rexml/document'
require 'stringio'
require 'logger'
require File.dirname(__FILE__) + '/osm.rb'

#Allows the live api to be queried

class Api

    def initialize(osm, config, log)
        #Osm object
        @osm = osm
        #Osm object to recieve live Primatives from api
        @new_osm = Osm.new(nil)
        #base URL of api server (http://www.openstreetmap.org/api/0.4)
        @api_server = config['api_server']
        #Logger to use for logging
        @log = log
    end

    #Checks each way matches the live version and deletes it if it does not.
    def refresh_way
        @osm.way.each_key do |way|
            @log.info('refreshing ' + way)
            response = query_server('/way/' + way)
            if !response.nil?
                xml = StringIO.new(response)
                importer = Xml_import_osm.new(@new_osm)
                listner = Listener.new(importer)
                REXML::Document.parse_stream(response, listner)
                if compare_way(@osm.way[way], @new_osm.way[way]) == false
                    #remove way
                    @log.debug(way + ' differs from live version')
                    @osm.way.delete(way)
                end
            else
                #remove way
                @log.debug(way + ' differs from live version')
                @osm.way.delete(way)
            end
        end
    end

    def refresh_node
        @osm.node.each_key do |node|
            #
        end
    end

    private

    def compare_tags(a, b)
        #compares tags, the same tags in a different order are considered equal
        equal = true
        a.each do |tag|
            if b.index(tag).nil?
                equal = false
            end
        end
        b.each do |tag|
            if a.index(tag).nil?
                equal = false
            end
        end
        equal
    end

    def compare_way(a, b)
        #checks if way a is the same as way b
        if a.segments != b.segments
            return false
        end
        compare_tags(a.tags, b.tags)
    end

    def query_server(command)
        @log.debug(@api_server + command)
        response = Net::HTTP.get_response(URI.parse(@api_server + command))
        @log.debug("response code = #{response.code}")
        if response.code == '200'
            return response.body
        else
            return nil
        end
    end

end
