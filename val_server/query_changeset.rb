
module QueryChangeset

    #find changeset
    def find_changset(id)
        primative = nil
        @db.execute("SELECT status FROM changeset WHERE id = ?", id) do |changeset|
            primative = Changeset.new
            primative.id = id
            primative.status = changeset[0]
            find_changeset_tag(id) do |tag|
                primative.tags.push(tag)
            end
        end
        return primative
    end
    
    # insert a new changeset
    def insert_changeset(changeset)
        if changeset.nil?
            @db.execute('INSERT INTO changeset DEFAULT VALUES')
            changeset = @db.last_insert_row_id
        end
        changeset
    end

    #close changeset
    def close_changeset(changeset)
        @db.execute('UPDATE changeset SET status = "closed" WHERE id = ?', changeset)
    end

    # instert a tag to the changeset_tag table
    def insert_changeset_tag(changeset, tag)
        @db.execute('INSERT INTO changeset_tag (changeset, tag) VALUES(?, ?)', changeset, insert_tag(tag))
    end

    # find all tags belonging to a changset
    def find_changeset_tag(changeset)
        @db.execute('SELECT tag.k, tag.v FROM changeset_tag INNER JOIN tag ON changeset_tag.tag = tag.id WHERE changeset_tag.changeset = ?', changeset) do |tag|
            yield tag
        end
    end


end

