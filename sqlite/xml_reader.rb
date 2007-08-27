
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

require File.dirname(__FILE__) + '/xml_import.rb'

class Listener

    def initialize(importer)
        @importer = importer
        @tag = nil
        @tag_id = nil
        @way_position = 0
    end

    def tag_start(name, attrs)
        case name
        when 'osm'
            #ignore osm tag
        when 'node'
            #set current tag
            raise 'tag within tag' if @tag.nil? == false
            @tag = 'node'
            @tag_id = attrs['id']
            #import node
            @importer.import_node(attrs['id'], attrs['lat'], attrs['lon'])
        when 'segment'
            raise 'tag within tag' if @tag.nil? == false
            @tag = 'segment'
            @tag_id = attrs['id']
            #import segment
            @importer.import_segment(attrs['id'], attrs['from'], attrs['to'])
        when 'way'
            raise 'tag within tag' if @tag.nil? == false
            @tag = 'way'
            @tag_id = attrs['id']
            @way_position = 0
        when 'seg'
            raise 'seg not in way' if @tag != 'way'
            #import way segment
            @importer.import_way(@tag_id, attrs['id'], @way_position)
            @way_position += 1
        when 'tag'
            raise 'tag without parent' if @tag.nil?
            #import tag
            case @tag
            when 'node'
                @importer.import_node_tag(@tag_id, attrs['k'], attrs['v'])
            when 'segment'
                @importer.import_segment_tag(@tag_id, attrs['k'], attrs['v'])
            when 'way'
                @importer.import_way_tag(@tag_id, attrs['k'], attrs['v'])
            end
        else
            puts "Unrecognised tag <#{name}>"
        end
    end

    def tag_end(name)
        @tag = nil if name == @tag
    end

    def method_missing(methodname, *args)
        #puts "method_missing: #{methodname}(#{args})"
    end
end