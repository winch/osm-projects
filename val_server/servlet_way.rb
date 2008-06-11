#--s
# $Id$

class ServletWay < HTTPServlet::AbstractServlet

    def initialize(config, database)
        super
        @db = Database.new(database)
    end
    
    def do_GET(req, res)
        #
    end
    
    def do_PUT(req, res)
        res['Content-Type'] = 'text/plain'
        
        #is the way being created or updated?
        action = req.path.split('/')[-1]
        
        #parse xml
        listner = XMLListener.new('way')
        REXML::Document.parse_stream(req.body, listner)
        way = listner.primative
        
        if action == 'create'
            #add way
            way.id = @db.insert_way(nil, way.nodes)
            res.body = way.id.to_s
        else
            #update way
            @db.update_way(way.id, way.nodes)
        end
        #insert tags
        way.tags.each do |tag|
            @db.insert_way_tag(way.id, tag)
        end
        
    end
    
    def do_DELETE(req, res)
        @db.remove_way(req.path.split('/')[-1])
    end
    
end
