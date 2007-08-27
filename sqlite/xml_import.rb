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

require File.dirname(__FILE__) + '/osm.rb'
require File.dirname(__FILE__) + '/database.rb'

class Xml_import_database

    def initialize(database)
        @db = database
        @tag_id = Hash.new()
    end

    def import_node(id, lat, lon)
        @db.insert_node.execute(id, lat, lon)
    end

    def import_node_tag(id, k, v)
        @db.insert_node_tag.execute(id, find_tag_id(k, v))
    end

    def import_segment(id, from, to)
        @db.insert_segment.execute(id, from, to)
    end

    def import_segment_tag(id, k, v)
        @db.insert_segment_tag.execute(id, find_tag_id(k, v))
    end

    def import_way(id, segment, position)
        @db.insert_way.execute(id, segment, position)
    end

    def import_way_tag(id, k, v)
        @db.insert_way_tag.execute(id, find_tag_id(k, v))
    end

    private

    #finds the id of a tag in the db and inserts tag if required
    def find_tag_id(k, v)
        id = nil
        if @tag_id[k + v].nil?
            #tag not in db
            @db.insert_tag.execute(k, v)
            @tag_id[k + v] = id = @db.db.last_insert_row_id
        else
            id = @tag_id[k + v]
        end
        id
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
