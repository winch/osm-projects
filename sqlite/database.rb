
# $Id$

class Database

    attr_reader :db
    #insert prepared statments
    attr_reader :insert_node, :insert_node_tag, :insert_segment, :insert_segment_tag
    attr_reader :insert_way, :insert_way_tag
    #export preparded statments
    attr_reader :export_way_tag, :export_way_segment, :export_segment_tag, :export_segment_node
    attr_reader :export_node_tag, :export_node, :export_node_from_segment, :export_node_at

    def initialize(file_name)
        @db = SQLite3::Database.new(file_name)
    end

    def prepare_import_statments
        #statements used during import
        @insert_node = @db.prepare("INSERT INTO node (id, lat, lon) VALUES(?, ?, ?)")
        @insert_node_tag = @db.prepare("INSERT INTO node_tag (id, k, v) VALUES(?, ?, ?)")
        @insert_segment = @db.prepare("INSERT INTO segment (id, node_a, node_b) VALUES(?, ?, ?)")
        @insert_segment_tag = @db.prepare("INSERT INTO segment_tag (id, k, v) VALUES(?, ?, ?)")
        @insert_way = @db.prepare("INSERT INTO way (id, segment, position) VALUES(?, ?, ?)")
        @insert_way_tag = @db.prepare("INSERT INTO way_tag (id, k, v) VALUES(?, ?, ?)")
    end

    def prepare_export_statments
        #statments used during export
        @export_way_tag = @db.prepare("select k, v from way_tag where id = ?")
        @export_way_segment = @db.prepare("select segment from way where id = ? order by position")
        @export_segment_tag = @db.prepare("select k, v from segment_tag where id = ?")
        @export_segment_node = @db.prepare("select node_a, node_b from segment where id = ?")
        @export_node_tag = @db.prepare("select k, v from node_tag where id = ?")
        @export_node = @db.prepare("select lat, lon from node where id = ?")
        @export_node_from_segment = @db.prepare("select id, lat, lon from node where id = ? or id = ?")
        @export_node_at =
            @db.prepare("select id, lat, lon from node where (lon > ? and lon < ?) and (lat > ? and lat < ?)")
    end

    def close
        #close prepared statments
        @insert_node.close if !@insert_node.nil?
        @insert_node_tag.close if !@insert_node_tag.nil?
        @insert_segment.close if !@insert_segment.nil?
        @insert_segment_tag.close if !@insert_segment_tag.nil?
        @insert_way.close if !@insert_way.nil?
        @insert_way_tag.close if !@insert_way_tag.nil?
        #export
        @export_way_tag.close if !@export_way_tag.nil?
        @export_way_segment.close if !@export_way_segment.nil?
        @export_segment_tag.close if !@export_segment_tag.nil?
        @export_segment_node.close if !@export_segment_node.nil?
        @export_node_tag.close if !@export_node_tag.nil?
        @export_node.close if !@export_node.nil?
        @export_node_from_segment.close if !@export_node_from_segment.nil?
        @export_node_at.close if !@export_node_at.nil?
        @db.close
    end

    def create_tables
        #node
        @db.execute('CREATE TABLE node(id NUMERIC, lat NUMERIC, lon NUMERIC)')
        @db.execute('CREATE TABLE node_tag(id NUMERIC, k TEXT, v TEXT)')
        #segment
        @db.execute('CREATE TABLE segment(id NUMERIC, node_a NUMERIC, node_b NUMERIC)')
        @db.execute('CREATE TABLE segment_tag(id NUMERIC, k TEXT, v TEXT)')
        #ways
        @db.execute('CREATE TABLE way(id INTEGER, segment NUMERIC, position NUMERIC)')
        @db.execute('CREATE TABLE way_tag(id NUMERIC, k TEXT, v TEXT)')
    end

     def create_index
        #node
        @db.execute('CREATE INDEX node_index on node(id)')
        @db.execute('CREATE INDEX node_tag_index on node_tag(id)')
        #segment
        @db.execute('CREATE INDEX segment_index on segment(id)')
        @db.execute('CREATE INDEX segment_tag_index on segment_tag(id)')
        #way
        @db.execute('CREATE INDEX way_index on way(id)')
        @db.execute('CREATE INDEX way_tag_index on way_tag(id)')
    end

end
