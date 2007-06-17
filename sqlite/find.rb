
# $Id$

class Osm
    attr_accessor :node, :segment, :way

    def initialize()
        @node = Hash.new
        @segment = Hash.new
        @way = Hash.new
    end

    def find_way_where(db, where_clause)
        #find all ways matching where_clause
        db.execute("select id from way_tag where " + where_clause) do |way|
            way = way[0]
            if @way[way].nil?
                #add way to @way
                item = Way.new
                #add tags
                db.execute("select k, v from way_tag where id = ?", way) do |tag|
                    item.tags.push(tag)
                end
                @way[way] = item
            end
            #find way segments
            db.execute("select segment from way where id = ? order by position", way) do |segment|
                @way[way].segments.push(segment[0])
            end
        end
    end

    def find_segment_where(db, where_clause)
        #find all segments matching where_clause
        db.execute("select id from segment_tag where " + where_clause) do |segment|
            segment = segment[0]
            if @segment[segment].nil?
                #add segment to @segment
                @segment[segment] = Segment.new
                #find segment attributes
                db.execute("select node_a, node_b from segment where id = ?", segment) do |segment_attr|
                    @segment[segment].node_a = segment_attr[0]
                    @segment[segment].node_b = segment_attr[1]
                end
                #add tags
                db.execute("select k, v from segment_tag where id = ?", segment) do |tag|
                    @segment[segment].tags.push(tag)
                end
            end
        end
    end

    def find_segment_from_way(db)
        #find all segments in @way
        @way.each_value do |way|
            way.segments.each do |segment|
                db.execute("select node_a, node_b from segment where id = ?", segment) do |nodes|
                    #add segment to @segment
                    if @segment[segment].nil?
                        item = Segment.new
                        item.node_a = nodes[0]
                        item.node_b = nodes[1]
                        @segment[segment] = item
                        #add tags
                        db.execute("select k, v from segment_tag where id = ?", segment) do |tag|
                            @segment[segment].tags.push(tag)
                        end
                    end
                end
            end
        end
    end

    def find_node_where(db, where_clause)
        #find all nodes matching where_clause
        db.execute("select id from node_tag where " + where_clause) do |node|
            if @node[node[0]].nil?
                @node[node[0]] = Node.new
                #find node attributes
                db.execute("select lat, lon from node where id = ?", node[0]) do |node_attr|
                    @node[node[0]].lat = node_attr[0]
                    @node[node[0]].lon = node_attr[1]
                end
                #add tags
                db.execute("select k, v from node_tag where id = ?", node[0]) do |tag|
                    @node[node[0]].tags.push(tag)
                end
            end
        end
    end

    def find_node_from_segment(db)
        #find all nodes in @segment
        @segment.each_value do |segment|
            db.execute("select id, lat, lon from node where id = ? or id = ?", segment.node_a, segment.node_b) do |node|
                if @node[node[0]].nil?
                    item = Node.new
                    item.lat = node[1]
                    item.lon = node[2]
                    @node[node[0]] = item
                    #add tags
                    db.execute("select k, v from node_tag where id = ?", node[0]) do |tag|
                        @node[node[0]].tags.push(tag)
                    end
                end
            end
        end
    end

end

