fs = require 'fs'
child_process = require 'child_process'

should = require 'should'
sqlite3 = (require 'sqlite3').verbose()

rss = require 'exportrss'

describe 'RSS', ->

  before (done) ->
    rss.Gather ->
      done()

  after (done) ->
    done()

  it 'the XML should be generated', ->
    rss.feed.xml().should.exist

