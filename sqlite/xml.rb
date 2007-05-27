
class Listener

    def initialize(db)
        @db = db
        @tag = nil
        @tag_id = nil
        @way_position = 0
    end

    def tag_start(name, attrs)
        case name
        when 'node'
            #set current tag
            raise 'tag within tag' if @tag.nil? == false
            @tag = 'node'
            @tag_id = attrs['id']
            #add node to db
            @db.execute("INSERT INTO node (id, lat, lon) VALUES(?, ?, ?)", attrs['id'], attrs['lat'], attrs['lon'])
        when 'segment'
            raise 'tag within tag' if @tag.nil? == false
            @tag = 'segment'
            @tag_id = attrs['id']
            #add segment to db
            @db.execute("INSERT INTO segment (id, node_a, node_b) VALUES(?, ?, ?)", attrs['id'], attrs['from'], attrs['to'])
        when 'way'
            raise 'tag within tag' if @tag.nil? == false
            @tag = 'way'
            @tag_id = attrs['id']
            @way_position = 0
        when 'seg'
            raise 'seg not in way' if @tag != 'way'
            #add way segment to db
            @db.execute("INSERT INTO way (id, segment, position) VALUES(?, ?, ?)", @tag_id, attrs['id'], @way_position)
            @way_position += 1
        when 'tag'
            raise 'tag without parent' if @tag.nil?
            #add tag to db, ignoring created_by tags
            if attrs['k'] != 'created_by'
                @db.execute("INSERT INTO #{@tag}_tag (id, k, v) VALUES(?, ?, ?)", @tag_id, attrs['k'], attrs['v'])
            end
        else
            puts "Unrecognised tag #{name}"
        end
    end

    def tag_end(name)
        @tag = nil if name == @tag
    end

    def method_missing(methodname, *args)
        #puts "method_missing: #{methodname}(#{args})"
    end
end