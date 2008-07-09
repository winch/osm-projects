#--
# $Id$

class Database

    #SQLite3::Database
    attr_reader :db
    
    def initialize(file_name)
        @db = SQLite3::Database.new(file_name)
    end
    
    def create_tables
        #gpx points
        @db.execute('CREATE TABLE IF NOT EXISTS gpx_point(lat NUMERIC, lon NUMERIC)')
        #md5 of gpx file to prevent files being imported more than once
        @db.execute('CREATE TABLE IF NOT EXISTS gpx_file(md5 TEXT)')
        
        #tags
        @db.execute('CREATE TABLE IF NOT EXISTS tag(id INTEGER PRIMARY KEY, k TEXT, v TEXT)')
        
        #nodes
        @db.execute('CREATE TABLE IF NOT EXISTS node(id INTEGER PRIMARY KEY, lat NUMERIC, lon NUMERIC)')
        @db.execute('CREATE TABLE IF NOT EXISTS node_tag(node NUMERIC, tag NUMERIC)')
        
        #ways
        @db.execute('CREATE TABLE IF NOT EXISTS way(id INTEGER PRIMARY KEY)')
        @db.execute('CREATE TABLE IF NOT EXISTS way_node(way NUMERIC, node NUMERIC, position NUMERIC)')
        @db.execute('CREATE TABLE IF NOT EXISTS way_tag(way NUMERIC, tag NUMERIC)')
    end
    
    def last_insert_id
        @db.last_insert_row_id
    end
    
    def close
        @db.close
    end
    
end

