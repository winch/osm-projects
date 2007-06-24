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

#++
#

require 'cgi'

class Xml_writer

    def initialize(stream)
        @output = stream
        @output.write('<?xml version="1.0" encoding="UTF-8"?>' + "\n")
        @output.write("<osm version=\"0.4\" generator=\"export.rb v#{$VERSION}\">\n")
    end

    def close()
        @output.write("</osm>\n")
    end

    def write_tag(tag)
        @output.write("    <tag k=\"#{tag[0]}\" v=\"#{CGI.escapeHTML(tag[1])}\"/>\n") if !tag[1].nil?
    end

    def get_action(primative)
        action = ''
        if !primative.action.nil?
            action = "action=\"#{primative.action}\""
        end
        action
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
        action = get_action(node)
        @output.write("  <node id=\"#{id}\" #{action} lat=\"#{node.lat}\" lon=\"#{node.lon}\"")
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
        action = get_action(segment)
        @output.write("  <segment id=\"#{id}\" #{action} from=\"#{segment.node_a}\" to=\"#{segment.node_b}\"")
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
        action = get_action(way)
        @output.write("  <way id=\"#{id}\" #{action}>\n")
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