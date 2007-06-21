
# $Id$

require 'net/http'
require 'uri'
require 'rexml/document'
require 'stringio'

class Api

    def initialize(osm, config)
        @osm = osm
        @new_osm = Osm.new(nil)
        @api_server = config['api_server']
    end

    def query_server(command)
        response = Net::HTTP.get_response(URI.parse(@api_server + command))
        if response.code == '200'
            return response.body
        else
            return nil
        end
    end

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

end
