
module QueryWay

    # find way
    def find_way(id)
        primative = nil
        @db.execute('SELECT node FROM way_node WHERE way = ? ORDER BY position', id) do |node|
            if primative.nil?
                primative = Way.new()
                primative.id = id
                find_way_tag(id) do |tag|
                    primative.tags.push(tag)
                end
            end
            primative.nodes.push(node[0])
        end
        return primative
    end

    # insert a new way
    def insert_way(way, nodes)
        position = 0
        nodes.each do |node|
            if way.nil?
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
    
    # find all ways that reference nodes in node_list
    def find_way_from_nodes(node_list)
        node_list.each do |node|
            @db.execute('SELECT way FROM way_node WHERE node = ?', node) do |way|
                yield way[0]
            end
        end
    end
    
    #find all nodes referenced by ways in way_list
    def find_node_from_ways(way_list)
        way_list.each do |way|
            @db.execute('SELECT node FROM way_node WHERE way = ?', way) do |node|
                yield node[0]
            end
        end
    end
    
    # instert a tag to the way_tag table
    def insert_way_tag(way, tag)
        @db.execute('INSERT INTO way_tag (way, tag) VALUES(?, ?)', way, insert_tag(tag))
    end
    
    # delete all tags belonging to a way
    def remove_way_tags(way)
        @db.execute('DELETE FROM way_tag WHERE way = ?', way)
    end

    # find all tags belonging to a way
    def find_way_tag(way)
        @db.execute('SELECT tag.k, tag.v FROM way_tag INNER JOIN tag ON way_tag.tag = tag.id WHERE way_tag.way = ?', way) do |tag|
            yield tag
        end
    end


end

