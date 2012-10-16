fs = require 'fs'
child_process = require 'child_process'

should = require 'should'
sqlite3 = (require 'sqlite3').verbose()

rss = require 'rss'

describe 'RSS', ->

  after (done) ->
    done()

  it 'should do something'

