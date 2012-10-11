should = require 'should'
loggit = require 'loggit'
fs = require 'fs'

describe 'Loggit', ->
  beforeEach ->
    fs.unlink __dirname + '/loggit.sqlite'
    # 'echo this is stdout &>1 this is stderr &>2'

  describe 'database schema', ->
    it 'should have 2 tables: loggit_process and loggit_message', (done) ->
      loggit.createTables (db) ->
        db.get "select * from sqlite_master", (error,rows) ->
          console.log rows
          done()