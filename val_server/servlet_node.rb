#--s
# $Id$

class ServletNode < HTTPServlet::AbstractServlet

    def initialize(config, database)
        super
        @db = DatabaseNode.new(database)
    end
    
    def do_GET(req, res)
        #
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
