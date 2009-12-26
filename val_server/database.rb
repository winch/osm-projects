#--
# $Id$

class Database

    #SQLite3::Database
    attr_reader :db
    
    def initialize(file_name)
        @db = SQLite3::Database.new(file_name)
        #mapping of tags to ids in database
        @tags = Hash.new
    end
    
    def create_tables
        #gpx points
        @db.execute('CREATE TABLE IF NOT EXISTS gpx_point(lat NUMERIC, lon NUMERIC)')
        #md5 of gpx file to prevent files being imported more than once
        @db.execute('CREATE TABLE IF NOT EXISTS gpx_file(md5 TEXT)')
        
        #tags
        @db.execute('CREATE TABLE IF NOT EXISTS tag(id INTEGER PRIMARY KEY, k TEXT, v TEXT)')
        
        #nodes
        @db.execute('CREATE TABLE IF NOT EXISTS node(id INTEGER PRIMARY KEY, lat NUMERIC, lon NUMERIC, version NUMERIC)')
        @db.execute('CREATE TABLE IF NOT EXISTS node_tag(node NUMERIC, tag NUMERIC)')
        
        #ways
        @db.execute('CREATE TABLE IF NOT EXISTS way(id INTEGER PRIMARY KEY, version NUMERIC)')
        @db.execute('CREATE TABLE IF NOT EXISTS way_node(way NUMERIC, node NUMERIC, position NUMERIC)')
        @db.execute('CREATE TABLE IF NOT EXISTS way_tag(way NUMERIC, tag NUMERIC)')
        
        #relations
        
        #changesets
        @db.execute('CREATE TABLE IF NOT EXISTS changeset(id INTEGER PRIMARY KEY)')
        @db.execute('CREATE TABLE IF NOT EXISTS changeset_tag(changeset NUMERIC, tag NUMERIC)')
    end
    
    def create_index
        #tags
        @db.execute('CREATE INDEX IF NOT EXISTS tag_index ON tag (id)')
        
        #nodes
        @db.execute('CREATE INDEX IF NOT EXISTS node_index ON node (id)')
        @db.execute('CREATE INDEX IF NOT EXISTS node_tag_index ON node_tag (node)')
        
        #ways
        @db.execute('CREATE INDEX IF NOT EXISTS way_node_index ON way_node (way)')
        @db.execute('CREATE INDEX IF NOT EXISTS way_tag_index ON way_tag (way)')
        
        #relations
        
        #changesets
        @db.execute('CREATE INDEX IF NOT EXISTS changeset_tag_index ON changeset_tag (changeset)')
    end
    
    def close
        @db.close
    end
    
end

