#!/usr/bin/env coffee

"""rss.coffee

Command line tool to create an RSS file from the loggit.sqlite
database.  The RSS file is written to loggit-rss.xml (it is
created if necessary).
"""

fs = require 'fs'
# https://github.com/dylang/node-rss
RSS = require 'rss'

sqlite3 = (require 'sqlite3').verbose()
db = new sqlite3.Database 'loggit.sqlite'

# :todo: We need to work out how to get the box name,
# so the feed_url is correct.
feed = new RSS
  title: 'loggit RSS feed',
  site_url: 'overview/',
  description: "Stuff from the loggit runs",
  author: 'The Box Author',
  feed_url: 'rss.xml'

# These functions are used later, see db.each.
eachRow = (err, row) ->
  feed.item
    title: row.command,
    url: 'http://api/sqlite?q=select*from+loggit_event+where+runid='+row.runid,
    date: row.timestamp,
    description: 'do not have one',
    guid: row.runid

allDone = ->
  fs.writeFile 'loggit-rss.xml', feed.xml(), ->

# "loop" over data and add to feed
db.each "select * from loggit_event where type='start'", eachRow, allDone
