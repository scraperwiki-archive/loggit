fs = require 'fs'
child_process = require 'child_process'

should = require 'should'
sqlite3 = (require 'sqlite3').verbose()

rss = require 'exportrss'

describe 'RSS', ->
  xml = null

  before (done) ->
    child_process.exec "cp test/fixture/loggit.sqlite loggit.sqlite", ->
      rss.Gather ->
        xml = rss.feed.xml()
        done()

  after (done) ->
    done()

  describe 'the XML', ->
    it 'should be generated', ->
      xml.should.exist

    it 'should contain exactly one item', ->
      m = xml.match /<item>/g
      should.exist m
      m.length.should.equal 1

