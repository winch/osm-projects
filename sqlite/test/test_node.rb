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

class TestNode < Test::Unit::TestCase

    #tests == method
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

    #tests to_xml method
    def test_node_to_xml
        #node with tags
        a = Node.new(1, 2)
        a.tags.push(['key', 'value & value'])
        a.tags.push(['highway', 'footway'])
        #node without tags
        b = Node.new(3, 4)
        #tests
        xml = a.to_xml(123).split("\n")
        assert_equal(4, xml.length)
        assert_equal('  <node id="123" lat="1" lon="2">', xml[0])
        assert_equal('    <tag k="key" v="value &amp; value"/>', xml[1])
        assert_equal('    <tag k="highway" v="footway"/>', xml[2])
        assert_equal('  </node>', xml[3])
        xml = b.to_xml(123).split("\n")
        assert_equal(1, xml.length)
        assert_equal('  <node id="123" lat="3" lon="4"/>', xml[0])
        puts xml[0]
        #node with action
        a.action = 'delete'
        b.action = 'modify'
        #tests
        xml = a.to_xml(123).split("\n")
        assert_equal(4, xml.length)
        assert_equal('  <node id="123" action="delete" lat="1" lon="2">', xml[0])
        xml = b.to_xml(123).split("\n")
        assert_equal(1, xml.length)
        assert_equal('  <node id="123" action="modify" lat="3" lon="4"/>', xml[0])
    end

end
