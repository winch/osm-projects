
module Find

    def Find.find_way_where(db, osm_way, where_clause)
        #find all ways matching where_clause
        db.execute("select id from way_tag where " + where_clause) do |way|
            way = way[0]
            if osm_way[way].nil?
                #add way to osm_way
                item = Way.new
                #add tags
                db.execute("select k, v from way_tag where id = ?", way) do |tag|
                    item.tags.push(tag)
                end
                osm_way[way] = item
            end
            #find way segments
            db.execute("select segment from way where id = ? order by position", way) do |segment|
                osm_way[way].segments.push(segment[0])
            end
        end
    end
    
    def Find.find_segment(db, osm_way, osm_segment)
        #find all segments in osm_way
        osm_way.each_value do |way|
            way.segments.each do |segment|
                db.execute("select node_a, node_b from segment where id = ?", segment) do |nodes|
                    #add segment to osm_segment
                    if osm_segment[segment].nil?
                        item = Segment.new
                        item.node_a = nodes[0]
                        item.node_b = nodes[1]
                        osm_segment[segment] = item
                        #add tags
                        db.execute("select k, v from segment_tag where id = ?", segment) do |tag|
                            osm_segment[segment].tags.push(tag)
                        end
                    end
                end
            end
        end
    end
    
    def Find.find_node(db, osm_segment, osm_node)
        #find all nodes in osm_segment
        osm_segment.each_value do |segment|
            db.execute("select id, lat, lon from node where id = ? or id = ?", segment.node_a, segment.node_b) do |node|
                if osm_node[node[0]].nil?
                    item = Node.new
                    item.lat = node[1]
                    item.lon = node[2]
                    osm_node[node[0]] = item
                    #add tags
                    db.execute("select k, v from node_tag where id = ?", node[0]) do |tag|
                        osm_node[node[0]].tags.push(tag)
                    end
                end
            end
        end
    end
    
    def Find.find_node_where(db, osm_node, where_clause)
        #find all nodes matching where_clause
        db.execute("select id from node_tag where " + where_clause) do |node|
            if osm_node[node[0]].nil?
                osm_node[node[0]] = Node.new
                #find node attributes
                db.execute("select lat, lon from node where id = ?", node[0]) do |node_attr|
                    osm_node[node[0]].lat = node_attr[0]
                    osm_node[node[0]].lon = node_attr[1]
                end
                #add tags
                db.execute("select k, v from node_tag where id = ?", node[0]) do |tag|
                    osm_node[node[0]].tags.push(tag)
                end
            end
        end
    end

end
