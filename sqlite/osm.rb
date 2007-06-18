
# $Id$

class Osm
    attr_accessor :node, :segment, :way

    def initialize(db)
        @node = Hash.new
        @segment = Hash.new
        @way = Hash.new
        @db = db
    end

    def find_way_where(where_clause)
        #find all ways matching where_clause
        @db.db.execute("select id from way_tag where " + where_clause) do |way|
            way = way[0]
            if @way[way].nil?
                #add way to @way
                item = Way.new
                #add tags
                @db.export_way_tag.execute(way) do |result|
                    result.each { |tag| item.tags.push(tag) }
                end
                @way[way] = item
            end
            #find way segments
            @db.export_way_segment.execute(way) do |result|
                result.each { |segment| @way[way].segments.push(segment[0]) }
            end
        end
    end

    def get_segment_tag(segment)
        @db.export_segment_tag.execute(segment) do |result|
            result.each { |tag| @segment[segment].tags.push(tag) }
        end
    end

    def find_segment_where(where_clause)
        #find all segments matching where_clause
        @db.db.execute("select id from segment_tag where " + where_clause) do |segment|
            segment = segment[0]
            if @segment[segment].nil?
                #add segment to @segment
                @segment[segment] = Segment.new
                #find segment attributes
                @db.export_segment_node.execute(segment) do |result|
                    result.each do |segment_attr|
                        @segment[segment].node_a = segment_attr[0]
                        @segment[segment].node_b = segment_attr[1]
                    end
                end
                #add tags
                get_segment_tag(segment)
            end
        end
    end

    def find_segment_from_way
        #find all segments in @way
        @way.each_value do |way|
            way.segments.each do |segment|
                @db.export_segment_node.execute(segment) do |result|
                    result.each do |nodes|
                        #add segment to @segment
                        if @segment[segment].nil?
                            item = Segment.new
                            item.node_a = nodes[0]
                            item.node_b = nodes[1]
                            @segment[segment] = item
                            #add tags
                            get_segment_tag(segment)
                        end
                    end
                end
            end
        end
    end

    def get_node_tag(node)
        @db.export_node_tag.execute(node[0]) do |result|
            result.each { |tag| @node[node[0]].tags.push(tag) }
        end
    end

    def find_node_where(where_clause)
        #find all nodes matching where_clause
        @db.db.execute("select id from node_tag where " + where_clause) do |node|
            if @node[node[0]].nil?
                @node[node[0]] = Node.new
                #find node attributes
                @db.export_node.execute(node[0]) do |result|
                    result.each do |node_attr|
                        @node[node[0]].lat = node_attr[0]
                        @node[node[0]].lon = node_attr[1]
                    end
                end
                #add tags
                get_node_tag(node)
            end
        end
    end

    def find_node_from_segment
        #find all nodes in @segment
        @segment.each_value do |segment|
            @db.export_node_from_segment.execute(segment.node_a, segment.node_b) do |result|
                result.each do |node|
                    if @node[node[0]].nil?
                        item = Node.new
                        item.lat = node[1]
                        item.lon = node[2]
                        @node[node[0]] = item
                        #add tags
                        get_node_tag(node)
                    end
                end
            end
        end
    end

end

