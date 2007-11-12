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

#Wrappes sqlite3 database.
#Creates required tables and indexes and manages prepared statements

class Database

    #SQLite3::Database
    attr_reader :db
    #insert prepared statement
    attr_reader :insert_node, :insert_node_tag, :insert_way, :insert_way_tag, :insert_node_relation,
                :insert_way_relation, :insert_relation_tag, :insert_tag
    #export preparded statement
    attr_reader :export_way_tag, :export_way_segment, :export_node_tag, :export_node,
                :export_node_from_segment, :export_node_at

    def initialize(file_name)
        @db = SQLite3::Database.new(file_name)
    end

    #prepare statements used during import
    def prepare_import_statements
        @insert_node = @db.prepare("INSERT INTO node (id, lat, lon) VALUES(?, ?, ?)")
        @insert_node_tag = @db.prepare("INSERT INTO node_tag (id, tag) VALUES(?, ?)")
        @insert_way = @db.prepare("INSERT INTO way (id, node, position) VALUES(?, ?, ?)")
        @insert_way_tag = @db.prepare("INSERT INTO way_tag (id, tag) VALUES(?, ?)")
        @insert_node_relation = @db.prepare("INSERT INTO node_relation(id, node, role) VALUES(?, ?, ?)")
        @insert_way_relation = @db.prepare("INSERT INTO way_relation(id, way, role) VALUES(?, ?, ?)")
        @insert_relation_tag = @db.prepare("INSERT INTO relation_tag (id, tag) VALUES(?, ?)")
        @insert_tag = @db.prepare("INSERT INTO tag (k, v) VALUES(?, ?)")
    end

    #prepare statements used during export and by server
    def prepare_export_statements
        @export_way_tag = @db.prepare("select k, v from tag where id in (select tag from way_tag where id = ?)")
        @export_way_segment = @db.prepare("select segment from way where id = ? order by position")
        @export_node_tag = @db.prepare("select k, v from tag where id in (select tag from node_tag where id = ?)")
        @export_node = @db.prepare("select lat, lon from node where id = ?")
        @export_node_from_segment = @db.prepare("select id, lat, lon from node where id = ? or id = ?")
        @export_node_at =
            @db.prepare("select id, lat, lon from node where (lon > ? and lon < ?) and (lat > ? and lat < ?)")
    end

    #close database and any existing prepared statements
    def close
        #import
        @insert_node.close if !@insert_node.nil?
        @insert_node_tag.close if !@insert_node_tag.nil?
        @insert_way.close if !@insert_way.nil?
        @insert_way_tag.close if !@insert_way_tag.nil?
        @insert_node_relation.close if !@insert_node_relation.nil?
        @insert_way_relation.close if !@insert_way_relation.nil?
        @insert_relation_tag.close if !@insert_relation_tag.nil?
        @insert_tag.close if !@insert_tag.nil?
        #export
        @export_way_tag.close if !@export_way_tag.nil?
        @export_way_segment.close if !@export_way_segment.nil?
        @export_node_tag.close if !@export_node_tag.nil?
        @export_node.close if !@export_node.nil?
        @export_node_from_segment.close if !@export_node_from_segment.nil?
        @export_node_at.close if !@export_node_at.nil?
        @db.close
    end

    #create database tables
    def create_tables
        #node
        @db.execute('CREATE TABLE node(id INTEGER PRIMARY KEY, lat NUMERIC, lon NUMERIC)')
        @db.execute('CREATE TABLE node_tag(id NUMERIC, tag NUMERIC)')
        #segment
        #ways
        @db.execute('CREATE TABLE way(id NUMERIC, node NUMERIC, position NUMERIC)')
        @db.execute('CREATE TABLE way_tag(id NUMERIC, tag NUMERIC)')
        #relations
        @db.execute('CREATE TABLE node_relation(id NUMERIC, node NUMERIC, role TEXT)')
        @db.execute('CREATE TABLE way_relation(id NUMERIC, way NUMERIC, role TEXT)')
        @db.execute('CREATE TABLE relation_tag(id NUMERIC, tag NUMERIC)')
        #tag
        @db.execute('CREATE TABLE tag(id INTEGER PRIMARY KEY, k TEXT, v TEXT)')
    end

    #create database indexes
    def create_index
        #node
        @db.execute('CREATE INDEX node_index on node(id)')
        @db.execute('CREATE INDEX node_tag_index on node_tag(id)')
        #way
        @db.execute('CREATE INDEX way_index on way(id)')
        @db.execute('CREATE INDEX way_tag_index on way_tag(id)')
        #tag
        @db.execute('CREATE INDEX tag_index on tag(id)')
    end

end
