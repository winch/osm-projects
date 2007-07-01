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

class TestSegment < Test::Unit::TestCase

    #tests == method
    def test_segment_equal
        a = Segment.new
        a.node_a = 123
        a.node_b = 456
        a.tags.push(['k', 'v'])
        a.tags.push(['v', 'k'])
        #b has different order tags
        b = Segment.new
        b.node_a = 123
        b.node_b = 456
        b.tags.push(['v', 'k'])
        b.tags.push(['k', 'v'])
        #c has different node_a
        c = Segment.new
        c.node_a = 321
        c.node_b = 456
        c.tags.push(['k', 'v'])
        c.tags.push(['v', 'k'])
        #d has different node_b
        d = Segment.new
        d.node_a = 123
        d.node_b = 321
        d.tags.push(['k', 'v'])
        d.tags.push(['v', 'k'])
        #e has different tags
        e = Segment.new
        e.node_a = 123
        e.node_b = 456
        e.tags.push(['v', 'k'])
        e.tags.push(['k', 'v'])
        e.tags.push(['kk', 'vv'])

        #tests
        assert_equal(true, a == b)
        assert_equal(false, a == c)
        assert_equal(false, a == d)
        assert_equal(false, a == e)
        assert_equal(false, e == a)
    end

    #tests to_xml method
    def test_segment_to_xml
        #segment with tags
        a = Segment.new
        a.node_a = 123
        a.node_b = 456
        a.tags.push(['highway', 'footway'])
        a.tags.push(['name', 'asdf'])
        #segment without tags
        b = Segment.new
        b.node_a = 789
        b.node_b = 654

        #tests
        xml = a.to_xml(321).split("\n")
        assert_equal(4, xml.length)
        assert_equal('  <segment id="321" from="123" to="456">', xml[0])
        assert_equal('    <tag k="highway" v="footway"/>', xml[1])
        assert_equal('    <tag k="name" v="asdf"/>', xml[2])
        assert_equal('  </segment>', xml[3])
        xml = b.to_xml(321).split("\n")
        assert_equal(1, xml.length)
        assert_equal('  <segment id="321" from="789" to="654"/>', xml[0])
        #segment with action
        b.action = 'modify'
        xml = b.to_xml(456).split("\n")
        assert_equal(1, xml.length)
        assert_equal('  <segment id="456" action="modify" from="789" to="654"/>', xml[0])
    end

end