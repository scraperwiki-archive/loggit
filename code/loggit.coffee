#!/usr/bin/env coffee

"""loggit command ...

Tool for logging output of a command to a sqlite database.
"""

spawn = (require 'child_process').spawn
fs = (require 'fs')
sqlite3 = (require 'sqlite3').verbose()

settings = JSON.parse (fs.readFileSync 'scraperwiki.json')

exports.createTables = (callback) ->
  db = new sqlite3.Database settings.database
  # The combination of runid and sequence is unique.
  db.run "create table if not exists
    loggit_event (runid, sequence, type, time, pid, command, data, exit_signal, exit_status)", ->
      callback db

exports.logMessages = (db) ->
  # Return a sequence number and timestamp for a child process.
  # *achild.seq* is assumed to be already initialised (to 0, when
  # the process is created).
  # A list of [seq, string] is returned.
  stamp = (achild) ->
      achild.seq += 1
      return [achild.seq, (new Date()).toISOString()]

  log = (child, ev) ->
      """Log an event (which is a structured object).  There are
      currently 4 event types identify by ev.type (start, stdout,
      stderr, exit).

      Events are logged to the loggit_event table in loggit.sqlite
      """
      st = stamp child
      if ev.type == 'start'
          db.run("insert into loggit_event (runid, sequence, type, time, pid, command) values (?, ?, ?, ?, ?, ?)",
            [child.runid, st[0], ev.type, st[1], child.pid, ev.command_line])
      if ev.type == 'stdout' or ev.type == 'stderr'
          db.run("insert into loggit_event (runid, sequence, type, time, data) values (?, ?, ?, ?, ?)",
            [child.runid, st[0], ev.type, st[1], ev.data])
      if ev.type == 'exit'
          db.run("insert into loggit_event (runid, sequence, type, time, exit_signal, exit_status) values (?, ?, ?, ?, ?, ?)",
            [child.runid, st[0], ev.type, st[1], ev.signal, ev.status])

  command = process.argv[2]
  child_arguments = process.argv[3..]
  child = spawn command, child_arguments
  child.seq = 0
  # 53 (?) bits of entropy from Math.random(). (Maybe. Possibly seeded from clock?)
  child.runid = (new Date().toISOString() + Math.random()).replace /\./g, ''

  log child,
      type: 'start'
      pid: child.pid
      command_line: ''+([command].concat(child_arguments))
            
  child.stdout.on 'data', (data) ->
    log child, { type: 'stdout', data: data }
  child.stderr.on 'data', (data) ->
    log child, { type: 'stderr', data: data }
  child.on 'exit', (code, signal) ->
    # :todo: could collect CPU usage here.
    log child, { type: 'exit', status: code, signal: signal }

# START
if process.argv[1].match /loggit\.coffee$/
  exports.createTables( exports.logMessages )
