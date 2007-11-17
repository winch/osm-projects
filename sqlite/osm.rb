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
    #for queries that use IN(list) split the list into chunks of @@chunk_size
    @@chunk_size = 10000
    #hash containing Node objects. Node id is used as key
    attr_accessor :node
    #hash containing Segment objects. Segment id is used as key
    attr_accessor :segment
    #hash containing Way objects. Way id is used as key
    attr_accessor :way
    #hash containing relation objects. Relation id is used as key
    attr_accessor :relation

    def initialize(db)
        @node = Hash.new
        @segment = Hash.new
        @way = Hash.new
        @relation = Hash.new
        @db = db
    end

    ######################
    # find node methods  #
    ######################

    #Populate @node with all nodes that match where_clause
    def find_node_where(where_clause)
        @db.db.execute("select id from node_tag where " + where_clause) do |node|
            @db.export_node.execute(node) do |result|
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

    #populate @node with all nodes in @way
    def find_node_from_way
        @way.each_value do |way|
            way.nodes.each do |node|
                @db.export_node.execute(node) do |result|
                    process_node(result)
                end
            end
        end
    end

    #####################
    # find way methods  #
    #####################

    #Populate @way with all ways that match where_clause
    def find_way_where(where_clause)
        @db.db.execute("select id from way_tag where " + where_clause) do |way|
            process_way(way)
        end
    end

    #populate @way with all ways referenced by @node
    def find_way_from_node
        node_list = @node.keys
        #split node list into chunks of nodes and process
        i = 0
        while node = node_list[i * @@chunk_size..i + 1 * @@chunk_size]
            n = node.join(',')
            @db.db.execute("SELECT id FROM way WHERE node IN(#{n})") do |way|
                process_way(way)
            end
            i += 1
        end
    end

    ##########################
    # find relation methods  #
    ##########################

    #populate @relation with all relations reference by @node or @way
    def find_relation
        #node relations
        node_list = @node.keys
        #split node list into chunks of nodes and process
        i = 0
        while node = node_list[i * @@chunk_size..i + 1 * @@chunk_size]
            n = node.join(',')
            @db.db.execute("SELECT id FROM node_relation WHERE node IN(#{n})") do |relation|
                process_relation(relation)
            end
            i += 1
        end
        #way relations
        way_list = @way.keys
        #split way list into chunks of ways and process
        i = 0
        while way = way_list[i * @@chunk_size..i + 1 * @@chunk_size]
            w = way.join(',')
            @db.db.execute("SELECT id FROM way_relation WHERE way IN(#{w})") do |relation|
                process_relation(relation)
            end
            i += 1
        end
    end

    ###########################
    # xml generation methods  #
    ###########################

    def to_xml(stream)
        stream.write('<?xml version="1.0" encoding="UTF-8"?>' + "\n")
        stream.write("<osm version=\"0.5\" generator=\"export.rb v#{$VERSION}\">\n")
        #node
        @node.each_value do |node|
            stream.write(node.to_xml)
        end
        #segment
        @segment.each_value do |segment|
            stream.write(segment.to_xml)
        end
        #way
        @way.each_value do |way|
            stream.write(way.to_xml)
        end
        #relation
        @relation.each_value do |relation|
            stream.write(relation.to_xml)
        end
        stream.write("</osm>\n")
    end

    ####################
    # private methods  #
    ####################

    private

    def process_relation(relation)
        relation = relation[0]
        if @relation[relation].nil?
            #add relation to relation
            item = Relation.new
            item.id = relation
            #add tags
            @db.export_relation_tag.execute(relation) do |result|
                result.each { |tag| item.tags.push(tag) }
            end
            #find node members
            @db.export_node_relation.execute(relation) do |result|
                result.each { |member| item.members.push(Member.new('node', member[0], member[1])) }
            end
            @db.export_way_relation.execute(relation) do |result|
                result.each { |member| item.members.push(Member.new('way', member[0], member[1])) }
            end
            #find way members
            @relation[relation] = item
        end
    end

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
            @db.export_way.execute(way) do |result|
                result.each { |node| item.nodes.push(node[0]) }
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

end

