
# $Id$

class Osm
    attr_accessor :node, :segment, :way

    def initialize(db)
        @node = Hash.new
        @segment = Hash.new
        @way = Hash.new
        @db = db
    end

    def process_way(way)
        way = way[0]
        if @way[way].nil?
            #add way to @way
            item = Way.new
            #add tags
            @db.export_way_tag.execute(way) do |result|
                result.each { |tag| item.tags.push(tag) }
            end
            #find way segments
            @db.export_way_segment.execute(way) do |result|
                result.each { |segment| item.segments.push(segment[0]) }
            end
            @way[way] = item
        end
    end 

    def find_way_where(where_clause)
        #find all ways matching where_clause
        @db.db.execute("select id from way_tag where " + where_clause) do |way|
            process_way(way)
        end
    end

    def find_way_from_segment
        #find all ways containg @segment
        s = @segment.keys.join(',')
        @db.db.execute("select id from way where segment in (#{s})") do |way|
            process_way(way)
        end
    end

    def get_segment_tag(segment)
        @db.export_segment_tag.execute(segment) do |result|
            result.each { |tag| @segment[segment].tags.push(tag) }
        end
    end

    def process_segment(segment, result)
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
                    self.process_segment(segment, result)
                end
            end
        end
    end

    def find_segment_from_node
        #find all segments in @node
        n = @node.keys.join(',')
        @db.db.execute("select id, node_a, node_b from segment where node_a in (#{n}) or node_b in (#{n})") do |segment|
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

    def get_node_tag(node)
        @db.export_node_tag.execute(node[0]) do |result|
            result.each { |tag| @node[node[0]].tags.push(tag) }
        end
    end

    def process_node(result)
        #processes a node result adding nodes to @node
        result.each do |node|
            if @node[node[0]].nil?
                @node[node[0]] = Node.new(node[1], node[2])
                #add tags
                get_node_tag(node)
            end
        end
    end

    def find_node_where(where_clause)
        #find all nodes matching where_clause
        @db.db.execute("select id from node_tag where " + where_clause) do |node|
            if @node[node[0]].nil?
                @node[node[0]] = Node.new(0,0)
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
                self.process_node(result)
            end
        end
    end

    def find_node_at(bbox)
        #find all nodes within bounding box
        @db.export_node_at.execute(bbox[0], bbox[2], bbox[1], bbox[3]) do |result|
            self.process_node(result)
        end
    end

end

