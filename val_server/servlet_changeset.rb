#--s
# $Id$

class ServletChangeset < HTTPServlet::AbstractServlet

    def initialize(config, database)
        super
        @db = DatabaseChangeset.new(database)
    end
    
    def do_GET(req, res)
        #get id and action
        query = req.path.split('/')
        id = query[3]
        action = nil
        if query.length > 4
            action = query[4]
        end
        
        if action.nil?
            #output changeset details
            res.body << "hello"
        end
    end
    
    def do_PUT(req, res)
        
        #is the changset being created, closed or modified
        action = req.path.split('/')[-1]
        
        changeset = nil
        #parse xml if create or modify
        if action =="create" and action != "close"
            listner = XMLListener.new('changeset', nil)
            REXML::Document.parse_stream(req.body, listner)
            changeset = listner.primative
        end
        
        if action == "create"
            res['Content-Type'] = 'text/plain'
            #create changeset
            changeset.id = @db.insert_changeset(nil)
            #insert tags
            changeset.tags.each do |tag|
                @db.insert_changeset_tag(changeset.id, tag)
            end
            #return changeset id
            res.body = changeset.id.to_s
        elsif action == "close"
            #close changset and return nothing
            @db.close_changeset(req.path.split('/')[-2])
        else
            #modify changset tags and return new changeset
            res['Content-Type'] = 'text/xml'
        end
    end
    
end

