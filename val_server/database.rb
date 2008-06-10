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
    end
    
    # insert a new node
    def insert_node(lat, lon)
        @db.execute('INSERT INTO node (lat, lon) VALUES(?, ?)', lat, lon)
        last_insert_id
    end
    
    #update an existing node
    def update_node(id, lat, lon)
        @db.execute('UPDATE node SET lat = ?, lon = ? WHERE id = ?', lat, lon, id)
    end
    
    # instert a tag to the node_tag table
    def insert_node_tag(node, tag)
        @db.execute('INSERT INTO node_tag (node, tag) VALUES(?, ?)', node, insert_tag(tag))
    end
    
    # delete all tags belonging to a node
    def remove_node_tag(node)
        @db.execute('DELETE FROM node_tag WHERE node = ?', node)
    end
    
    # insert the tag into the tag table if required and return the tag id
    def insert_tag(tag)
        #check if tag exists
        id = nil
        @db.execute('SELECT id FROM tag WHERE k = ? AND v = ? LIMIT 1', tag[0], tag[1]) do |tag|
            id = tag[0]
        end
        if id == nil
            #tag does not exist, insert it
            @db.execute('INSERT INTO tag (k, v) VALUES(?, ?)', tag[0], tag[1])
            id = last_insert_id
        end
        id
    end
    
    def last_insert_id
        @db.last_insert_row_id
    end
    
    def close
        @db.close
    end
    
end

