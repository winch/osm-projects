#--s
# $Id$

class ServletChangeset < HTTPServlet::AbstractServlet

    def initialize(config, database)
        super
        @db = DatabaseChangeset.new(database)
    end
    
    def do_GET(req, res)
        #get id and action
        res['Content-Type'] = 'text/xml'
        query = req.path.split('/')
        id = query[4]
        action = nil
        if query.length > 4
            action = query[5]
        end
        
        if action.nil? or action == 'history'
            #output changeset details
            changeset = @db.find_changset(id)
            if changeset.nil?
                raise HTTPStatus::NotFound
            else
                res.body << "<?xml version='1.0' encoding='UTF-8'?>\n"
                res.body << "<osm version='#{$API_VERSION}' generator='server.rb #{$VERSION}'>\n"
                res.body << changeset.to_xml
                res.body << "</osm>\n"
            end
        end
    end

    def do_POST(req, res)
        #parse osm change data
        #return response xml
        res['Content-Type'] = 'text/xml'
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

