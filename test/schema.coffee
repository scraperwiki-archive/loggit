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

    it 'should have 2 tables: loggit_process and loggit_event', (done) ->
        db.get "select * from loggit_process", ->
          db.get "select * from loggit_event", done

    describe 'loggit_process', ->
      it 'should have the right columns', (done) ->
        db.get "select runid, pid, command from loggit_process", done


    describe 'loggit_event', ->
      it 'should have the right columns', (done) ->
        db.get "select runid, type, time, sequence, data, exit_signal, exit_code from loggit_event", done

  describe 'when command is run with loggit', ->
    before (done) ->
      db = new sqlite3.Database 'loggit.sqlite'
      child_process.exec "loggit 'echo this is stderr 1>&2 && echo this is stdout'", done

    describe '... process ...', ->
      it 'has recorded the process', (done) ->
        db.all "select * from loggit_process", (err, rows) ->
          rows.length.should.equal 1
          done()


    describe '... events ...', ->
      it 'has recorded a start event', (done) ->
        db.all "select * from loggit_event where type='start'", (err, rows) ->
          rows.length.should.equal 1
          done()

      it 'has recorded a stderr event', (done) ->
        db.all "select * from loggit_event where type='stderr'", (err, rows) ->
          rows.length.should.equal 1
          done()

      it 'has recorded a stdout event', (done) ->
        db.all "select * from loggit_event where type='stdout'", (err, rows) ->
          rows.length.should.equal 1
          done()

      it 'has recorded an exit event', (done) ->
        db.all "select * from loggit_event where type='exit'", (err, rows) ->
          rows.length.should.equal 1
          done()
