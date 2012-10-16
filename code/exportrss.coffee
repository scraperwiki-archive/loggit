#!/usr/bin/env coffee

"""rss.coffee

Command line tool to create an RSS file from the loggit.sqlite
database.  The RSS file is written to loggit-rss.xml (it is
created if necessary).
"""

# The exports in this file, are only there so that they can be
# exported to the script that tests them.

fs = require 'fs'
# https://github.com/dylang/node-rss
RSS = require 'rss'

sqlite3 = (require 'sqlite3').verbose()
db = new sqlite3.Database 'loggit.sqlite'

# :todo: We need to work out how to get the box name,
# so the feed_url is correct.
boxname = 'exampleorg/project'

# :todo: Fetch description from scraperwiki.json, if it exists.

feed = new RSS
  title: 'loggit RSS feed',
  site_url: 'overview/',
  description: "Stuff from the loggit runs",
  author: 'The Box Author',
  feed_url: 'rss.xml'
exports.feed = feed

# Note that Gather uses callbacks defined just after.
exports.Gather = (done) ->
  db.each "select * from loggit_event where type='start'", eachRow, done
Gather = exports.Gather

eachRow = (err, row) ->
  feed.item
    title: row.command,
    url: 'http://box.scraperwiki.com/'+boxname+'/sqlite?q=select*from+loggit_event+where+runid='+row.runid,
    date: row.timestamp,
    description: 'do not have one',
    guid: row.runid

allDone = ->
  fs.writeFile 'loggit-rss.xml', feed.xml(), ->

main = ->
  Gather allDone

# START
if process.argv[1].match /rss\.coffee$/
  main()
