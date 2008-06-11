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
    
    # insert a new node
    def insert_node(lat, lon)
        @db.execute('INSERT INTO node (lat, lon) VALUES(?, ?)', lat, lon)
        last_insert_id
    end
    
    #update an existing node
    def update_node(id, lat, lon)
        @db.execute('UPDATE node SET lat = ?, lon = ? WHERE id = ?', lat, lon, id)
    end
    
    #remove an existing node
    def remove_node(node)
        remove_node_tag(node)
        @db.execute('DELETE FROM node where id = ?', node)
    end
    
    # instert a tag to the node_tag table
    def insert_node_tag(node, tag)
        @db.execute('INSERT INTO node_tag (node, tag) VALUES(?, ?)', node, insert_tag(tag))
    end
    
    # delete all tags belonging to a node
    def remove_node_tag(node)
        @db.execute('DELETE FROM node_tag WHERE node = ?', node)
    end
    
    # insert a new way
    def insert_way(way, nodes)
        position = 0
        nodes.each do |node|
            if way == nil
                @db.execute('INSERT INTO way DEFAULT VALUES')
                way = @db.last_insert_row_id
            end
            @db.execute('INSERT INTO way_node (way, node, position) VALUES(?, ?, ?)', way, node, position)
            position += 1
        end
        way
    end
    
    # update an existing way
    def update_way(way, nodes)
        #delete current way nodes
        remove_way_nodes(way)
        #insert way
        insert_way(way, nodes)
    end
    
    # remove existing way nodes
    def remove_way_nodes(way)
        @db.execute('DELETE FROM way_node where way = ?', way)
    end
    
    # remove an existing way
    def remove_way(way)
        remove_way_tags(way)
        remove_way_nodes(way)
        @db.execute('DELETE FROM way WHERE id = ?', way)
    end
    
    # instert a tag to the way_tag table
    def insert_way_tag(way, tag)
        @db.execute('INSERT INTO way_tag (way, tag) VALUES(?, ?)', way, insert_tag(tag))
    end
    
    # delete all tags belonging to a way
    def remove_way_tags(way)
        @db.execute('DELETE FROM way_tag WHERE way = ?', way)
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

