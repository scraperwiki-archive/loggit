fs = require 'fs'
child_process = require 'child_process'

should = require 'should'
sqlite3 = (require 'sqlite3').verbose()

loggit = require 'loggit'

describe 'Loggit', ->
  db = null

  after (done) ->
    fs.unlink 'loggit.sqlite', (err) ->
      done()

  describe 'database schema', ->

    before (done) ->
      loggit.createTables (d) ->
        db = d
        done()

    it 'should have a loggit_event table', (done) ->
      db.get "select * from loggit_event", done

    it 'should have the right columns', (done) ->
      db.get "select runid, type, time, sequence, pid, command, data, exit_signal, exit_status from loggit_event", done

  describe 'when command is run with loggit', ->

    before (done) ->
      db = new sqlite3.Database 'loggit.sqlite'
      child_process.exec "bin/loggit sh -c '{echo this is stderr 1>&2 ; echo this is stdout}'", done

    it 'has recorded a start event', (done) ->
      db.all "select * from loggit_event where type='start'", (err, rows) ->
        rows.length.should.not.equal 0
        done()

    it 'has recorded a stderr event', (done) ->
      db.all "select * from loggit_event where type='stderr'", (err, rows) ->
        rows.length.should.not.equal 0
        done()

    it 'has recorded a stdout event', (done) ->
      db.all "select * from loggit_event where type='stdout'", (err, rows) ->
        rows.length.should.not.equal 0
        done()

    it 'has recorded an exit event', (done) ->
      db.all "select * from loggit_event where type='exit'", (err, rows) ->
        rows.length.should.not.equal 0
        done()
