#!/usr/bin/ruby

#imports planet file into sqlite db

require 'sqlite3'
require 'osm/sqlite/primative.rb'
require 'osm/sqlite/xml_write.rb'

if ARGV.length != 2
    puts 'export.rb database.db output.osm'
    exit
end

db = SQLite3::Database.new(ARGV[0])
output = File.open(ARGV[1], "w")
output.write('<?xml version="1.0" encoding="UTF-8"?>' + "\n")
output.write('<osm version="0.4" generator="export.rb">' + "\n")

osm_node = Hash.new
osm_segment = Hash.new
osm_way = Hash.new

db.execute("select id from way_tag where v='Oxford Canal'") do |way|
    way = way[0]
    if osm_way[way].nil?
        #add way to osm_way
        item = Way.new
        #add tags
        db.execute("select k, v from way_tag where id = ?", way) do |tag|
            item.tags.push(tag)
        end
        osm_way[way] = item
    end
    #find way segments
    db.execute("select segment from way where id = ? order by position", way) do |segment|
        osm_way[way].segments.push(segment[0])
    end
end

#find segments
osm_way.each_value do |way|
    way.segments.each do |segment|
        db.execute("select node_a, node_b from segment where id = ?", segment) do |nodes|
            #add segment to osm_segment
            if osm_segment[segment].nil?
                item = Segment.new
                item.node_a = nodes[0]
                item.node_b = nodes[1]
                osm_segment[segment] = item
                #add tags
                db.execute("select k, v from segment_tag where id = ?", segment) do |tag|
                    osm_segment[segment].tags.push(tag)
                end
            end
        end
    end
end

#find nodes
osm_segment.each_value do |segment|
    db.execute("select id, lat, lon from node where id = ? or id = ?", segment.node_a, segment.node_b) do |node|
        if osm_node[node[0]].nil?
            item = Node.new
            item.lat = node[1]
            item.lon = node[2]
            osm_node[node[0]] = item
            #add tags
            db.execute("select k, v from node_tag where id = ?", node[0]) do |tag|
                osm_node[node[0]].tags.push(tag)
            end
        end
    end
end

#write osm data

#node
osm_node.each do |id, node|
    Xml.write_node(output, id, node)
end

#segment
osm_segment.each do |id, segment|
    Xml.write_segment(output, id, segment)
end

#way
osm_way.each do |id, way|
    Xml.write_way(output, id, way)
end

output.write("</osm>\n")
output.close
db.close
