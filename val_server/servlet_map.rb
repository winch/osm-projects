#--
# $Id$

class ServletMap < HTTPServlet::AbstractServlet

    def initialize(config, database)
        super
    end
    
    def do_GET(req, res)
        if req.query['bbox']
            bbox = req.query['bbox'].split(',')
            if bbox.length != 4
                raise HTTPStatus::PreconditionFailed.new("badly formatted attribute: 'bbox'")
            end
        else
            raise HTTPStatus::PreconditionFailed.new("missing attribute: 'bbox'")
        end
    end
    
end
