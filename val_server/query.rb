
module Query
    
    # insert the tag into the tag table if required and return the tag id
    def insert_tag(tag)
        #check if tag exists
        id = @tags[tag]
        id = nil
        if id == nil
            @db.execute('SELECT id FROM tag WHERE k = ? AND v = ? LIMIT 1', tag[0], tag[1]) do |tag|
                id = tag[0]
            end
            if id == nil
                #tag does not exist, insert it
                @db.execute('INSERT INTO tag (k, v) VALUES(?, ?)', tag[0], tag[1])
                id = last_insert_id
            end
            #@tags[tag] = id
        end
        id
    end
    
    # get id of last inserted row
    def last_insert_id
        @db.last_insert_row_id
    end

end

