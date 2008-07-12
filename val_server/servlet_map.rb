#--
# $Id$

class ServletMap < HTTPServlet::AbstractServlet

    def initialize(config, database)
        super
        @db = DatabaseMap.new(database)
    end
    
    def do_GET(req, res)
        if req.query['bbox']
            bbox = req.query['bbox'].split(',')
            if bbox.length != 4
                raise HTTPStatus::PreconditionFailed.new("badly formatted attribute: 'bbox'")
            end
            
            node_list = Hash.new
            way_list = Hash.new
            
            #xml header
            res.body = "<?xml version='1.0' encoding='UTF-8'?>\n"
            res.body << "<osm version='#{$API_VERSION}' generator='server.rb #{$VERSION}'>"
            
            #find nodes
            @db.find_node_at(bbox) do |node|
                node_list[node] = true
            end
            
            #find ways
            @db.find_way_from_nodes(node_list) do |way|
                way_list[way] = true
            end
            
            #find all way nodes
            @db.find_node_from_ways(way_list) do |node|
                node_list[node] = true
            end
            
            #export nodes
            node_list.each_key do |node|
                primative = @db.find_node(node)
                if primative.nil? == false
                    res.body << primative.to_xml
                end
            end
            
            #export ways
            way_list.each_key do |way|
                primative = @db.find_way(way)
                if primative.nil? == false
                    res.body << primative.to_xml
                end
            end
            
            #find relations
            
            res.body << "</osm>\n"
        else
            raise HTTPStatus::PreconditionFailed.new("missing attribute: 'bbox'")
        end
    end
    
end
