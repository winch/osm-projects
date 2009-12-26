#--
# $Id$

class ServletCapabilities < HTTPServlet::AbstractServlet

    def initialize(config)
        super
    end

    def do_GET(req, res)
        res.body << "<?xml version='1.0' encoding='UTF-8'?>\n"
        res.body << "<osm version='#{$API_VERSION}' generator='server.rb #{$VERSION}'>\n"
        res.body << "  <api>\n"
        res.body << "    <version minimum='#{$API_VERSION}' maximum='#{$API_VERSION}'/>\n"
        res.body << "    <area maximum='0.25'/>\n"
        res.body << "    <tracepoints per_page='5000'/>\n"
        res.body << "    <waynodes maximum='2000'/>\n"
        res.body << "    <changesets maximum_elements='50000'/>\n"
        res.body << "    <timeout seconds='300'/>\n"
        res.body << "  </api>\n"
        res.body << "</osm>\n"
    end
    
end

