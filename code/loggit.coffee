#!/usr/bin/env coffee

"""loggit command ...

Tool for logging output of a command to a sqlite database.
"""

spawn = (require 'child_process').spawn

sqlite3 = (require 'sqlite3').verbose()
_s = require 'underscore.string'

exports.createTables = (callback) ->
  db = new sqlite3.Database 'loggit.sqlite'
  # For all these tables, (id, sequence) is unique.
  db.run "create table if not exists
    loggit_process (runid, pid, command)", ->
    db.run "create table if not exists
      loggit_event (runid, type, time, sequence, data, exit_signal, exit_code)", ->
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

      Events are logged to the tables loggit_start, loggit_exit,
      loggit_data in the sqlite file loggit.sqlite
      """
      st = stamp child
      # :todo: in future, write to some sort of DB.
      if ev.type == 'start'
          db.run("insert into loggit_event values(?, ?, ?, ?, NULL, NULL, NULL)",
            [child.runid, ev.type, st[1], st[0]])
      if ev.type == 'stdout' or ev.type == 'stderr'
          console.log ev.type
          db.run("insert into loggit_event values(?, ?, ?, ?, ?, NULL, NULL)",
            [child.runid, ev.type, st[1], st[0], ev.data])
      if ev.type == 'exit'
          db.run("insert into loggit_event values(?, ?, ?, ?, NULL, ?, ?)",
            [child.runid, ev.type, st[1], st[0], ev.signal, ev.status])

  command = process.argv[2]
  child_arguments = process.argv[3..]
  child = spawn command, child_arguments
  child.seq = 0
  # 106 (?) bits of entropy.
  child.runid = (Math.random() + '' + Math.random()).replace /\./g, ''

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
if _s.endsWith process.argv[1], 'loggit.coffee'
  exports.createTables( exports.logMessages )
