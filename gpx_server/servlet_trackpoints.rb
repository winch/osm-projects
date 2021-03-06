#--
# $Id$
#
#Copyright (C) 2007 David Dent
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

class ServletTrackpoints < HTTPServlet::AbstractServlet

    def initialize(config, database)
        super
        @db = Database.new(database)
        @db.prepare_export_statements
    end

    def do_GET(req, res)
        if req.query['bbox'] && req.query['page']
            bbox = req.query['bbox'].split(',')
            if bbox.length != 4
                raise HTTPStatus::PreconditionFailed.new("badly formatted attribute: 'bbox'")
            end
            page = req.query['page'].to_i
            res['Content-Type'] = 'Content-Type: text/xml; charset=utf-8'
            @logger.info("find_gpx_| #{req.query['bbox']}")
            @logger.info("page #{page}")
            res.body = "<?xml version='1.0' encoding='UTF-8'?>\n"
            res.body << "<gpx version='1.0' creator='gpx_server #{$VERSION}' xmlns='http://www.topografix.com/GPX/1/0/'>\n"
            res.body << " <trk>\n"
            res.body << "  <trkseg>\n"
            total = 0
            bbox[0] = bbox[0].to_f
            bbox[1] = bbox[1].to_f
            bbox[2] = bbox[2].to_f
            bbox[3] = bbox[3].to_f
            @db.export_point_page.execute(bbox[0], bbox[2], bbox[1], bbox[3], $POINTS_PAGE, page * $POINTS_PAGE) do |result|
                result.each do |point|
                    res.body << "   <trkpt lat='#{point[0].to_f}' lon='#{point[1].to_f}'/>\n"
                    total += 1
                end
            end
            res.body << "  </trkseg>\n"
            res.body << " </trk>\n"
            res.body << "</gpx>\n"
            @db.close
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
