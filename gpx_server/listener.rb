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

class Listener

    attr_reader :count

    def initialize(db)
        @db = db
        @count = 0
    end

    def zero_count
        @count = 0
    end

    def tag_start(name, attrs)
        if name == 'trkpt'
            #import point
            @db.insert_point.execute(attrs['lat'], attrs['lon'])
            @count += 1
        end
    end

    def method_missing(methodname, *args)
        #puts "method_missing: #{methodname}(#{args})"
    end
end