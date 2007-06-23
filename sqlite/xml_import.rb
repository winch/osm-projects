
# $Id$

require File.dirname(__FILE__) + '/osm.rb'

class Xml_import_database

    def initialize(database)
        @db = database
    end

    def import_node(id, lat, lon)
        @db.insert_node.execute(id, lat, lon)
    end

    def import_node_tag(id, k, v)
        @db.insert_node_tag.execute(id, k, v)
    end

    def import_segment(id, from, to)
        @db.insert_segment.execute(id, from, to)
    end

    def import_segment_tag(id, k, v)
        @db.insert_segment_tag.execute(id, k, v)
    end

    def import_way(id, segment, position)
        @db.insert_way.execute(id, segment, position)
    end

    def import_way_tag(id, k, v)
        @db.insert_way_tag.execute(id, k, v)
    end

end

class Xml_import_osm

    def initialize(osm)
        @osm = osm
    end

    def import_node(id, lat, lon)
        if @osm.node[id].nil?
            @osm.node[id] = Node.new(lat, lon)
        end
    end

    def import_node_tag(id, k, v)
        #
    end

    def import_segment(id, from, to)
        #
    end

    def import_segment_tag(id, k, v)
        #
    end

    def import_way(id, segment, position)
        if @osm.way[id].nil?
            @osm.way[id] = Way.new
        end
        @osm.way[id].segments.push(segment)
    end

    def import_way_tag(id, k, v)
        if @osm.way[id].nil?
            @osm.way[id] = Way.new
        end
        @osm.way[id].tags.push([k, v])
    end

end
