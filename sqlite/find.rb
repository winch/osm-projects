
# $Id$

module Find

    def Find.find_way_where(db, osm, where_clause)
        #find all ways matching where_clause
        db.execute("select id from way_tag where " + where_clause) do |way|
            way = way[0]
            if osm.way[way].nil?
                #add way to osm.way
                item = Way.new
                #add tags
                db.execute("select k, v from way_tag where id = ?", way) do |tag|
                    item.tags.push(tag)
                end
                osm.way[way] = item
            end
            #find way segments
            db.execute("select segment from way where id = ? order by position", way) do |segment|
                osm.way[way].segments.push(segment[0])
            end
        end
    end

    def Find.find_segment_where(db, osm, where_clause)
        #find all segments matching where_clause
        db.execute("select id from segment_tag where " + where_clause) do |segment|
            segment = segment[0]
            if osm.segment[segment].nil?
                #add segment to osm.segment
                osm.segment[segment] = Segment.new
                #find segment attributes
                db.execute("select node_a, node_b from segment where id = ?", segment) do |segment_attr|
                    osm.segment[segment].node_a = segment_attr[0]
                    osm.segment[segment].node_b = segment_attr[1]
                end
                #add tags
                db.execute("select k, v from segment_tag where id = ?", segment) do |tag|
                    osm.segment[segment].tags.push(tag)
                end
            end
        end
    end

    def Find.find_segment_from_way(db, osm)
        #find all segments in osm.way
        osm.way.each_value do |way|
            way.segments.each do |segment|
                db.execute("select node_a, node_b from segment where id = ?", segment) do |nodes|
                    #add segment to osm.segment
                    if osm.segment[segment].nil?
                        item = Segment.new
                        item.node_a = nodes[0]
                        item.node_b = nodes[1]
                        osm.segment[segment] = item
                        #add tags
                        db.execute("select k, v from segment_tag where id = ?", segment) do |tag|
                            osm.segment[segment].tags.push(tag)
                        end
                    end
                end
            end
        end
    end

    def Find.find_node_where(db, osm, where_clause)
        #find all nodes matching where_clause
        db.execute("select id from node_tag where " + where_clause) do |node|
            if osm.node[node[0]].nil?
                osm.node[node[0]] = Node.new
                #find node attributes
                db.execute("select lat, lon from node where id = ?", node[0]) do |node_attr|
                    osm.node[node[0]].lat = node_attr[0]
                    osm.node[node[0]].lon = node_attr[1]
                end
                #add tags
                db.execute("select k, v from node_tag where id = ?", node[0]) do |tag|
                    osm.node[node[0]].tags.push(tag)
                end
            end
        end
    end

    def Find.find_node_from_segment(db, osm)
        #find all nodes in osm.segment
        osm.segment.each_value do |segment|
            db.execute("select id, lat, lon from node where id = ? or id = ?", segment.node_a, segment.node_b) do |node|
                if osm.node[node[0]].nil?
                    item = Node.new
                    item.lat = node[1]
                    item.lon = node[2]
                    osm.node[node[0]] = item
                    #add tags
                    db.execute("select k, v from node_tag where id = ?", node[0]) do |tag|
                        osm.node[node[0]].tags.push(tag)
                    end
                end
            end
        end
    end

end
