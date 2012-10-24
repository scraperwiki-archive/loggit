#!/usr/bin/env coffee

###
rss.coffee

Command line tool to create an RSS file from the loggit.sqlite
database.  The RSS file is written to loggit-rss.xml (it is
created if necessary).
###

# The exports in this file, are only there so that they can be
# exported to the script that tests them.

fs = require 'fs'
# https://github.com/dylang/node-rss
RSS = require 'rss'

sqlite3 = (require 'sqlite3').verbose()
db = new sqlite3.Database 'loggit.sqlite'

child_process = require 'child_process'

feed = null
boxname = null
boxurl = null

if process.argv[2]
  filename = process.argv[2]
else
  filename = 'loggit-rss.xml'

# Note that Gather uses callbacks defined just after.
exports.Gather = (done) ->
  child_process.exec 'whoami', (err, stdout, stderr) ->
    boxname = stdout.toString().replace(/\s/g, '').replace('.','/')
    # :todo: this ignores the fact there might be a publish_token set.
    boxurl = 'https://box.scraperwiki.com/' + boxname + '/'
    feed = new RSS
      title: 'loggit RSS feed',
      site_url: boxurl + 'http/',
      description: "Stuff from the loggit runs",
      author: 'The Box Author',
      feed_url: boxurl + 'http/' + filename
    exports.feed = feed
    db.each "select * from loggit_event where type='start'", eachRow, done
Gather = exports.Gather

eachRow = (err, row) ->
  feed.item
    title: row.command,
    url: boxurl + 'sqlite?q=select*from+loggit_event+where+runid='+row.runid,
    date: row.timestamp,
    description: 'do not have one',
    guid: row.runid

allDone = ->
  fs.writeFile filename, feed.xml(), (error, result) ->
    if error then console.log error

main = ->
  Gather allDone

# START
if process.argv[1].match /rss\.coffee$/
  main()
