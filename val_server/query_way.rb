
module QueryWay

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

end

