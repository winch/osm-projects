#!/usr/bin/env ruby

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

require 'test/unit'
require File.dirname(__FILE__) + '/../primative.rb'

class TestPrimative < Test::Unit::TestCase

    def test_node_equal
        a = Node.new(1, 2)
        a.tags.push(['k', 'v'])
        a.tags.push(['v', 'k'])
        #b has different order tags
        b = Node.new(1, 2)
        b.tags.push(['v', 'k'])
        b.tags.push(['k', 'v'])
        #c has different lon
        c = Node.new(1, 3)
        c.tags.push(['k', 'v'])
        c.tags.push(['v', 'k'])
        #d has different tags
        d = Node.new(1, 2)
        d.tags.push(['v', 'k'])
        d.tags.push(['k', 'v'])
        d.tags.push(['kk', 'vv'])

        #tests
        assert_equal(true, a == b)
        assert_equal(true, b == a)
        assert_equal(false, a == c)
        assert_equal(false, c == a)
        assert_equal(false, a == d)
        assert_equal(false, d == a)
    end

    def test_node_to_xml
        a = Node.new(1, 2)
        a.tags.push(['key', 'value & value'])
        a.tags.push(['highway', 'footway'])
        b = Node.new(3, 4)
    end

end
