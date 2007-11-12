
#Objects representing OSM data primatives
#http://wiki.openstreetmap.org/index.php/Data_Primitives

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

#cgi required for escapeHTML method used to escape tag values
require 'cgi'

#Base primative class
class Primative
    #id
    attr_accessor :id
    #array containing tags as key, value pairs.
    attr_accessor :tags
    #if !nil value will be written in action attribute when output as osm xml.
    #osm xml can then be loaded in JOSM and action performed when uploaded.
    attr_accessor :action

    def initialize
        @tags = Array.new
        @action = nil
    end

    #The same tags in a different order are considered equal.
    def ==(other)
        if @id != other.id
            return false
        end
        equal = true
        @tags.each do |tag|
            if other.tags.index(tag).nil?
                equal = false
            end
        end
        other.tags.each do |tag|
            if @tags.index(tag).nil?
                equal = false
            end
        end
        equal
    end

    #returns the tags in osm xml
    def to_xml
        xml = ''
        @tags.each do |tag|
            if tag[0] != nil && tag[1] != nil
                xml << "    <tag k=\"#{tag[0]}\" v=\"#{CGI.escapeHTML(tag[1])}\"/>\n"
            else
                puts "id |#{@id}| tag[0] |#{tag[0]}| tag[1] |#{tag[1]}|"
            end
        end
        xml
    end

end

#Node data primative
class Node < Primative
    #lattitute of node
    attr_accessor :lat
    #longitude of note
    attr_accessor :lon

    def initialize(lat, lon)
        super()
        @lat = lat
        @lon = lon
    end

    def ==(other)
        if (@lat == other.lat) && (@lon == other.lon)
            return super(other)
        end
        false
    end

    #returns node in osm xml
    def to_xml
        action = ' '
        if !@action.nil?
            action = " action=\"#{@action}\" "
        end
        xml = "  <node id=\"#{@id}\"#{action}lat=\"#{@lat}\" lon=\"#{@lon}\""
        if @tags.empty?
            #no tags so close node
            xml << "/>\n"
        else
            xml << ">\n"
            xml << super << "  </node>\n"
        end
        xml
    end

end

#way data primative
class Way < Primative
    #list of segments that make up the way
    attr_accessor :segments

    def initialize
        super
        @segments = Array.new
    end

    def ==(other)
        if (@segments == other.segments)
            return super(other)
        end
        false
    end

    #returns way in osm xml
    def to_xml
        action = ''
        if !@action.nil?
            action = " action=\"#{@action}\""
        end
        xml = "  <way id=\"#{id}\"#{action}>\n"
        @segments.each do |segment|
            xml << "    <seg id=\"#{segment}\"/>\n"
        end
        xml << super << "  </way>\n"
    end

end