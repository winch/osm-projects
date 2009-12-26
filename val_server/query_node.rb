
module QueryNode

    #find node
    def find_node(id)
        primative = nil
        @db.execute('SELECT lat, lon, version FROM node WHERE id = ?', id) do |node|
            primative = Node.new(node[0], node[1])
            primative.id = id
            primative.version = node[2]
            find_node_tag(primative.id) do |tag|
                primative.tags.push(tag)
            end
        end
        return primative
    end

    #find all nodes in bbox
    def find_node_at(bbox)
        @db.execute('SELECT id FROM node WHERE lat < ? and lat > ? and
                    lon > ? and lon < ?', bbox[3], bbox[1], bbox[0], bbox[2]) do |node|
            yield(node[0])
        end
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
    
    # find all tags belonging to a node
    def find_node_tag(node)
        @db.execute('SELECT tag.k, tag.v FROM node_tag INNER JOIN tag ON node_tag.tag = tag.id WHERE node_tag.node = ?', node) do |tag|
            yield tag
        end
    end

end

