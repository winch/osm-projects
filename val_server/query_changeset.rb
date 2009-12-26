
module QueryChangeset

    #find changeset
    def find_changset(id)
        #
    end
    
    # insert a new changeset
    def insert_changeset(changeset)
        if changeset.nil?
            @db.execute('INSERT INTO changeset DEFAULT VALUES')
            changeset = @db.last_insert_row_id
        end
        changeset
    end

    # instert a tag to the changeset_tag table
    def insert_changeset_tag(changeset, tag)
        @db.execute('INSERT INTO changeset_tag (changeset, tag) VALUES(?, ?)', changeset, insert_tag(tag))
    end

end

