#--s
# $Id$

class ServletNode < HTTPServlet::AbstractServlet

    def initialize(config, database)
        super
        @db = DatabaseNode.new(database)
    end
    
    def do_GET(req, res)
         #get id and action
        query = req.path.split('/')
        id = query[3]
        action = nil
        if query.length > 4
            action = query[4]
        end
        
        if action.nil? or action == 'history'
            #output node details
            node = @db.find_node(id)
            res.body << "<?xml version='1.0' encoding='UTF-8'?>\n"
            res.body << "<osm version='#{$API_VERSION}' generator='server.rb #{$VERSION}'>\n"
            res.body << node.to_xml
            res.body << "</osm>\n"
        end
    end
    
    def do_PUT(req, res)
        res['Content-Type'] = 'text/plain'
        
        #is the node being created or updated?
        action = req.path.split('/')[-1]
        
        #parse xml
        listner = XMLListener.new('node', nil)
        REXML::Document.parse_stream(req.body, listner)
        node = listner.primative
        
        if action == 'create'
            #add node
            node.id = @db.insert_node(node.lat, node.lon)
            res.body = node.id.to_s
        else
            #update node
            @db.update_node(node.id, node.lat, node.lon)
            #delete any existing tags
            @db.remove_node_tag(node.id)
        end
        #insert tags
        node.tags.each do |tag|
            @db.insert_node_tag(node.id, tag)
        end
        
    end
    
    def do_DELETE(req, res)
        @db.remove_node(req.path.split('/')[-1])
    end
    
end
