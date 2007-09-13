
class ServletTrackpoints < HTTPServlet::AbstractServlet

    def do_GET(req, res)
        if req.query['bbox'] && req.query['page']
            bbox = req.query['bbox'].split(',')
            if bbox.length != 4
                raise HTTPStatus::PreconditionFailed.new("badly formatted attribute: 'bbox'")
            end
            @db = Database.new(database)
            @db.prepare_export_statements
            page = req.query['page'].to_i
            res['Content-Type'] = 'Content-Type: text/xml; charset=utf-8'
            @logger.info("find_gpx_| #{req.query['bbox']}")
            @logger.info("page #{page}")
            res.body = "<?xml version='1.0' encoding='UTF-8'?>\n"
            res.body << "<gpx version='1.0' creator='gpx_server #{$VERSION}' xmlns='http://www.topografix.com/GPX/1/0/'>\n"
            res.body << " <trk>\n"
            res.body << "  <trkseg>\n"
            total = 0
            bbox[0] = bbox[0].to_f * 1000000
            bbox[1] = bbox[1].to_f * 1000000
            bbox[2] = bbox[2].to_f * 1000000
            bbox[3] = bbox[3].to_f * 1000000
            @db.export_point.execute(bbox[0], bbox[2], bbox[1], bbox[3], $POINTS_PAGE, page * $POINTS_PAGE) do |result|
                result.each do |point|
                    res.body << "   <trkpt lat='#{point[0].to_f / 1000000}' lon='#{point[1].to_f / 1000000}'/>\n"
                    total += 1
                end
            end
            res.body << "  </trkseg>\n"
            res.body << " </trk>\n"
            res.body << "</gpx>\n"
            db.close
            @logger.info("exported #{total} points")
            raise HTTPStatus::OK
        else
            if !req.query['bbox']
                raise HTTPStatus::PreconditionFailed.new("missing attribute: 'bbox'")
            else
                raise HTTPStatus::PreconditionFailed.new("missing attribute: 'page'")
            end
        end
    end
end
