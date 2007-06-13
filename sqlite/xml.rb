
class Listener

    def initialize(db)
        @db = db
        @tag = nil
        @tag_id = nil
        @way_position = 0

        #prepare statments
        @insert_node = @db.prepare("INSERT INTO node (id, lat, lon) VALUES(?, ?, ?)")
        @insert_node_tag = @db.prepare("INSERT INTO node_tag (id, k, v) VALUES(?, ?, ?)")
        @insert_segment = @db.prepare("INSERT INTO segment (id, node_a, node_b) VALUES(?, ?, ?)")
        @insert_segment_tag = @db.prepare("INSERT INTO segment_tag (id, k, v) VALUES(?, ?, ?)")
        @insert_way = @db.prepare("INSERT INTO way (id, segment, position) VALUES(?, ?, ?)")
        @insert_way_tag = @db.prepare("INSERT INTO way_tag (id, k, v) VALUES(?, ?, ?)")
    end

    def close
        @insert_node.close
        @insert_node_tag.close
        @insert_segment.close
        @insert_segment_tag.close
        @insert_way.close
        @insert_way_tag.close
    end

    def tag_start(name, attrs)
        case name
        when 'node'
            #set current tag
            raise 'tag within tag' if @tag.nil? == false
            @tag = 'node'
            @tag_id = attrs['id']
            #add node to db
            @insert_node.execute(attrs['id'], attrs['lat'], attrs['lon'])
        when 'segment'
            raise 'tag within tag' if @tag.nil? == false
            @tag = 'segment'
            @tag_id = attrs['id']
            #add segment to db
            @insert_segment.execute(attrs['id'], attrs['from'], attrs['to'])
        when 'way'
            raise 'tag within tag' if @tag.nil? == false
            @tag = 'way'
            @tag_id = attrs['id']
            @way_position = 0
        when 'seg'
            raise 'seg not in way' if @tag != 'way'
            #add way segment to db
            @insert_way.execute(@tag_id, attrs['id'], @way_position)
            @way_position += 1
        when 'tag'
            raise 'tag without parent' if @tag.nil?
            #add tag to db, ignoring created_by tags
            if attrs['k'] != 'created_by'
                case @tag
                when 'node'
                    statement = @insert_node_tag
                when 'segment'
                    statement = @insert_segment_tag
                when 'way'
                    statement = @insert_way_tag
                end
                statement.execute(@tag_id, attrs['k'], attrs['v'])
            end
        else
            puts "Unrecognised tag <#{name}>"
        end
    end

    def tag_end(name)
        @tag = nil if name == @tag
    end

    def method_missing(methodname, *args)
        #puts "method_missing: #{methodname}(#{args})"
    end
end