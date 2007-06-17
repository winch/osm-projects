
# $Id$

require 'cgi'

class Xml_writer

    def initialize(filename)
        @output = File.open(filename, "w")
        @output.write('<?xml version="1.0" encoding="UTF-8"?>' + "\n")
        @output.write("<osm version=\"0.4\" generator=\"export.rb v#{$VERSION}\">\n")
    end

    def close()
        @output.write("</osm>\n")
        @output.close
    end

    def write_tag(tag)
        @output.write("    <tag k=\"#{tag[0]}\" v=\"#{CGI.escapeHTML(tag[1])}\"/>\n") if !tag[1].nil?
    end

    def write(osm)
        #node
        osm.node.each do |id, node|
            self.write_node(id, node)
        end
        #segment
        osm.segment.each do |id, segment|
            self.write_segment(id, segment)
        end
        #way
        osm.way.each do |id, way|
            self.write_way(id, way)
        end
    end

    def write_node(id, node)
        @output.write("  <node id=\"#{id}\" lat=\"#{node.lat}\" lon=\"#{node.lon}\"")
        if node.tags.empty?
            #no tags so close node
            @output.write("/>\n")
        else
            @output.write(">\n")
            node.tags.each do |tag|
                write_tag(tag)
            end
            @output.write("  </node>\n")
        end
    end

    def write_segment(id, segment)
        @output.write("  <segment id=\"#{id}\" from=\"#{segment.node_a}\" to=\"#{segment.node_b}\"")
        if segment.tags.empty?
            #no tags so close segment
            @output.write("/>\n")
        else
            @output.write(">\n")
            segment.tags.each do |tag|
                write_tag(tag)
            end
            @output.write("  </segment>\n")
        end
    end

    def write_way(id, way)
        @output.write("  <way id=\"#{id}\">\n")
        #segments
        way.segments.each do |segment|
            @output.write("    <seg id=\"#{segment}\"/>\n")
        end
        #tags
        way.tags.each do |tag|
            write_tag(tag)
        end
        @output.write("  </way>\n")
    end

end