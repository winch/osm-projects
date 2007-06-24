
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

#Base primative class
class Primative
    #array containing tags as key, value pairs.
    attr_accessor :tags
    #if !nil value will be written in action attribute when output as osm xml.
    #osm xml can then be loaded in JOSM and action performed when uploaded.
    attr_accessor :action

    def initialize
        @tags = Array.new
        @action = nil
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

end

#Segment data primative
class Segment < Primative
    #node id that the segment points from
    attr_accessor :node_a
    #node id that the segment points to
    attr_accessor :node_b
end

#way data primative
class Way < Primative
    #list of segments that make up the way
    attr_accessor :segments

    def initialize
        super
        @segments = Array.new
    end
end