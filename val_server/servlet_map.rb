#--
# $Id$

class ServletMap < HTTPServlet::AbstractServlet

    def initialize(config, database)
        super
        @db = DatabaseMap.new(database)
        @node = Array.new
        @way = Array.new
        @relation = Array.new
    end
    
    def do_GET(req, res)
        if req.query['bbox']
            bbox = req.query['bbox'].split(',')
            if bbox.length != 4
                raise HTTPStatus::PreconditionFailed.new("badly formatted attribute: 'bbox'")
            end
            
            #find nodes
            @db.find_node_at(bbox) do |node|
                @node.push(node)
                
            end
            
            #output xml
            res.body = "<?xml version='1.0' encoding='UTF-8'?>\n"
            res.body << "<osm version='#{$API_VERSION}' generator='server.rb #{$VERSION}'>"
            #nodes
            @node.each do |node|
                res.body << node.to_xml
            end
            #ways
            #relations
            res.body << "</osm>\n"
        else
            raise HTTPStatus::PreconditionFailed.new("missing attribute: 'bbox'")
        end
    end
    
end
