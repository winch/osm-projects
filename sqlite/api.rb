
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
require File.dirname(__FILE__) + '/osm.rb'

class Api

    def initialize(osm, config)
        @osm = osm
        @new_osm = Osm.new(nil)
        @api_server = config['api_server']
    end

    def refresh_way
        @osm.way.each_key do |way|
            puts 'refreshing ' + way
            response = query_server('/way/' + way)
            if !response.nil?
                xml = StringIO.new(response)
                importer = Xml_import_osm.new(@new_osm)
                listner = Listener.new(importer)
                REXML::Document.parse_stream(response, listner)
                if compare_way(@osm.way[way], @new_osm.way[way]) == false
                    #remove way
                    @osm.way.delete(way)
                end
            else
                #remove way
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

    def compare_way(a, b)
        if a.segments != b.segments
            return false
        end
        equal = true
        a.tags.each do |tag|
            if b.tags.index(tag).nil?
                equal = false
            end
        end
        equal
    end

    def query_server(command)
        response = Net::HTTP.get_response(URI.parse(@api_server + command))
        if response.code == '200'
            return response.body
        else
            return nil
        end
    end

end
