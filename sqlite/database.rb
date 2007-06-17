
# $Id$

class Database

    attr_reader :db
    #insert prepared statments
    attr_reader :insert_node, :insert_node_tag, :insert_segment, :insert_segment_tag
    attr_reader :insert_way, :insert_way_tag

    def initialize(file_name)
        @db = SQLite3::Database.new(file_name)
    end

    def prepare_import_statments
        @insert_node = @db.prepare("INSERT INTO node (id, lat, lon) VALUES(?, ?, ?)")
        @insert_node_tag = @db.prepare("INSERT INTO node_tag (id, k, v) VALUES(?, ?, ?)")
        @insert_segment = @db.prepare("INSERT INTO segment (id, node_a, node_b) VALUES(?, ?, ?)")
        @insert_segment_tag = @db.prepare("INSERT INTO segment_tag (id, k, v) VALUES(?, ?, ?)")
        @insert_way = @db.prepare("INSERT INTO way (id, segment, position) VALUES(?, ?, ?)")
        @insert_way_tag = @db.prepare("INSERT INTO way_tag (id, k, v) VALUES(?, ?, ?)")
    end

    def close
        #close prepared statments
        @insert_node.close if !@insert_node.nil?
        @insert_node_tag.close if !@insert_node_tag.nil?
        @insert_segment.close if !@insert_segment.nil?
        @insert_segment_tag.close if !@insert_segment_tag.nil?
        @insert_way.close if !@insert_way.nil?
        @insert_way_tag.close if !@insert_way_tag.nil?
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
