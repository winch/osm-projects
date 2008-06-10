#--
# $Id$

class ServletTrackpoints < HTTPServlet::AbstractServlet

    def initialize(config, database)
        super
    end
    
    def do_GET(req, res)
        if req.query['bbox'] && req.query['page']
            bbox = req.query['bbox'].split(',')
            if bbox.length != 4
                raise HTTPStatus::PreconditionFailed.new("badly formatted attribute: 'bbox'")
            end
        else
            if !req.query['bbox']
                raise HTTPStatus::PreconditionFailed.new("missing attribute: 'bbox'")
            else
                raise HTTPStatus::PreconditionFailed.new("missing attribute: 'page'")
            end
        end
    end
    
end
