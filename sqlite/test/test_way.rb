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

class TestWay < Test::Unit::TestCase

    #tests == method
    def test_way_equal
        a = Way.new
        a.id = 789
        a.segments.push(123)
        a.segments.push(456)
        a.tags.push(['k', 'v'])
        a.tags.push(['v', 'k'])
        #different order tags
        b = Way.new
        b.id = 789
        b.segments.push(123)
        b.segments.push(456)
        b.tags.push(['v', 'k'])
        b.tags.push(['k', 'v'])
        #different segments
        c = Way.new
        c.id = 789
        c.segments.push(123)
        c.segments.push(321)
        c.tags.push(['k', 'v'])
        c.tags.push(['v', 'k'])
        #differet tags
        d = Way.new
        d.id = 789
        d.segments.push(123)
        d.segments.push(456)
        d.tags.push(['k', 'v'])
        d.tags.push(['v', 'k'])
        d.tags.push(['highway', 'footway'])
        #different id
        e = Way.new
        e.id = 123
        e.segments.push(123)
        e.segments.push(456)
        e.tags.push(['k', 'v'])
        e.tags.push(['v', 'k'])

        #tests
        assert_equal(true, a == b)
        assert_equal(false, a == c)
        assert_equal(false, a == d)
        assert_equal(false, d == a)
        assert_equal(false, a == e)
    end

    #tests to_xml method
    def test_way_sto_xml
        #way with tags
        a = Way.new
        a.id = 789
        a.segments.push(123)
        a.segments.push(456)
        a.tags.push(['some', 'tag'])
        a.tags.push(['highway', 'footway'])
        #way without tags
        b = Way.new
        b.id = 123
        b.action = 'delete'
        b.segments.push(254)
        b.segments.push(631)

        #tests
        xml = a.to_xml.split("\n")
        assert_equal(6, xml.length)
        assert_equal('  <way id="789">', xml[0])
        assert_equal('    <seg id="123"/>', xml[1])
        assert_equal('    <seg id="456"/>', xml[2])
        assert_equal('    <tag k="some" v="tag"/>', xml[3])
        assert_equal('    <tag k="highway" v="footway"/>', xml[4])
        assert_equal('  </way>', xml[5])
        #without tags
        xml = b.to_xml.split("\n")
        assert_equal(4, xml.length)
        assert_equal('  <way id="123" action="delete">', xml[0])
        assert_equal('    <seg id="254"/>', xml[1])
        assert_equal('    <seg id="631"/>', xml[2])
        assert_equal('  </way>', xml[3])
    end

end