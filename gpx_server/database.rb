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

    #insert prepared statements
    attr_reader :insert_point, :check_md5, :insert_md5

    #export prepared statement
    attr_reader :export_point_page, :export_point_all

    #prepare statements used during import
    def prepare_import_statements
        @insert_point = @db.prepare("INSERT INTO point (lat, lon) VALUES(?, ?)")
        @check_md5 = db.prepare("SELECT COUNT(*) FROM file WHERE md5 = ?")
        @insert_md5 = db.prepare("INSERT INTO file (md5) VALUES(?)")
    end

    #prepare statements used during export
    def prepare_export_statements
        @export_point_page =
        @db.prepare("select lat, lon from point where (lon between ? and ?) and (lat between ? and ?) limit ? offset ?")
        @export_point_all = @db.prepare("select lat, lon from point where (lon between ? and ?) and (lat between ? and ?) ")
    end

    def initialize(file_name)
        @db = SQLite3::Database.new(file_name)
    end

    #create database tables
    def create_tables
        @db.execute('CREATE TABLE IF NOT EXISTS point(lat NUMERIC, lon NUMERIC)')
        @db.execute('CREATE TABLE IF NOT EXISTS file(md5 TEXT)')
    end

    #close database and any prepared statements
    def close
        #import
        @insert_point.close if !@insert_point.nil?
        @check_md5.close if !@check_md5.nil?
        @insert_md5.close if !@insert_md5.nil?
        #export
        @export_point_page.close if !@export_point_page.nil?
        @export_point_all.close if !@export_point_all.nil?
        @db.close
    end

end
