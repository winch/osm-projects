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

#Wrappes sqlite3 database.
#Creates required tables and indexes and manages prepared statements

class Database

    #SQLite3::Database
    attr_reader :db

    #insert prepared statement
    attr_reader :insert_point

    #export prepared statement
    attr_reader :export_point

    #prepare statements used during import
    def prepare_import_statements
        @insert_point = @db.prepare("INSERT INTO point (lat, lon) VALUES(?, ?)")
    end

    #prepare statements used during export
    def prepare_export_statements
        @export_point =
        @db.prepare("select lat, lon from point where (lon between ? and ?) and (lat between ? and ?) limit ? offset ?")
    end

    def initialize(file_name)
        @db = SQLite3::Database.new(file_name)
    end

    #create database tables
    def create_tables
        @db.execute('CREATE TABLE IF NOT EXISTS point(lat NUMERIC, lon NUMERIC)')
    end

    #close database and any prepared statements
    def close
        #import
        @insert_point.close if !@insert_point.nil?
        #export
        @export_point.close if !@export_point.nil?
        @db.close
    end

end
