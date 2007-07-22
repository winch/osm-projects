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

require File.dirname(__FILE__) + '/primative.rb'

#Container for Primative types.
#Methods to extract Primative types from database
class Osm
    #hash containing Node objects. Node id is used as key
    attr_accessor :node
    #hash containing Segment objects. Segment id is used as key
    attr_accessor :segment
    #hash containing Way objects. Way id is used as key
    attr_accessor :way

    def initialize(db)
        @node = Hash.new
        @segment = Hash.new
        @way = Hash.new
        @db = db
    end

    #Populate @way with all ways that match where_clause
    def find_way_where(where_clause)
        @db.db.execute("select id from way_tag where " + where_clause) do |way|
            process_way(way)
        end
    end

    #Populate @way with all ways that reference @segment
    def find_way_from_segment
        s = @segment.keys.join(',')
        @db.db.execute("select id from way where segment in (#{s})") do |way|
            process_way(way)
        end
    end

    #Populate @segment with all segments that match where_clause
    def find_segment_where(where_clause)
        @db.db.execute("select id from segment_tag where " + where_clause) do |segment|
            segment = segment[0]
            if @segment[segment].nil?
                #add segment to @segment
                @segment[segment] = Segment.new
                #find segment attributes
                @segment[segment].id = segment
                @db.export_segment_node.execute(segment) do |result|
                    result.each do |segment_attr|
                        @segment[segment].node_a = segment_attr[0]
                        @segment[segment].node_b = segment_attr[1]
                    end
                end
                #add tags
                get_segment_tag(segment)
            end
        end
    end

    #Populate @segments with all segments referenced in @way
    def find_segment_from_way
        @way.each_value do |way|
            way.segments.each do |segment|
                @db.export_segment_node.execute(segment) do |result|
                    process_segment(segment, result)
                end
            end
        end
    end

    #Populate @segment with all segments that refrence @node
    def find_segment_from_node
        n = @node.keys.join(',')
        @db.db.execute("select id, node_a, node_b from segment where node_a in (#{n}) or node_b in (#{n})") do |segment|
            segment = segment[0]
            if @segment[segment].nil?
                #add segment to @segment
                @segment[segment] = Segment.new
                #find segment attributes
                @segment[segment].id = segment
                @db.export_segment_node.execute(segment) do |result|
                    result.each do |segment_attr|
                        @segment[segment].node_a = segment_attr[0]
                        @segment[segment].node_b = segment_attr[1]
                    end
                end
                #add tags
                get_segment_tag(segment)
            end
        end
    end

    #Populate @node with all nodes that match where_clause
    def find_node_where(where_clause)
        @db.db.execute("select id from node_tag where " + where_clause) do |node|
            if @node[node[0]].nil?
                @node[node[0]] = Node.new(0,0)
                #find node attributes
                @node[node[0]].id = node[0]
                @db.export_node.execute(node[0]) do |result|
                    result.each do |node_attr|
                        @node[node[0]].lat = node_attr[0]
                        @node[node[0]].lon = node_attr[1]
                    end
                end
                #add tags
                get_node_tag(node)
            end
        end
    end

    #Populate @node with all nodes referenced by @segment
    def find_node_from_segment
        @segment.each_value do |segment|
            @db.export_node_from_segment.execute(segment.node_a, segment.node_b) do |result|
                process_node(result)
            end
        end
    end

    #find all nodes within bounding box.
    def find_node_at(bbox)
        @db.export_node_at.execute(bbox[0], bbox[2], bbox[1], bbox[3]) do |result|
            process_node(result)
        end
    end

    def to_xml(stream)
        stream.write('<?xml version="1.0" encoding="UTF-8"?>' + "\n")
        stream.write("<osm version=\"0.4\" generator=\"export.rb v#{$VERSION}\">\n")
        #node
        @node.each do |id, node|
            stream.write(node.to_xml)
        end
        #segment
        @segment.each do |id, segment|
            stream.write(segment.to_xml)
        end
        #way
        @way.each do |id, way|
            stream.write(way.to_xml)
        end
        stream.write("</osm>\n")
    end

    private

    def process_way(way)
        way = way[0]
        if @way[way].nil?
            #add way to @way
            item = Way.new
            item.id = way
            #add tags
            @db.export_way_tag.execute(way) do |result|
                result.each { |tag| item.tags.push(tag) }
            end
            #find way segments
            @db.export_way_segment.execute(way) do |result|
                result.each { |segment| item.segments.push(segment[0]) }
            end
            @way[way] = item
        end
    end

    def get_node_tag(node)
        @db.export_node_tag.execute(node[0]) do |result|
            result.each { |tag| @node[node[0]].tags.push(tag) }
        end
    end

    def process_node(result)
        #processes a node result adding nodes to @node
        result.each do |node|
            if @node[node[0]].nil?
                @node[node[0]] = Node.new(node[1], node[2])
                @node[node[0]].id = node[0]
                #add tags
                get_node_tag(node)
            end
        end
    end

    def get_segment_tag(segment)
        @db.export_segment_tag.execute(segment) do |result|
            result.each { |tag| @segment[segment].tags.push(tag) }
        end
    end

    def process_segment(segment, result)
        result.each do |nodes|
            #add segment to @segment
            if @segment[segment].nil?
                item = Segment.new
                item.id = segment
                item.node_a = nodes[0]
                item.node_b = nodes[1]
                @segment[segment] = item
                #add tags
                get_segment_tag(segment)
            end
        end
    end

end

