# loggit #

A tool to log a command's activity to a SQLite database.

Prefixing your normal commands with `loggit` will capture:
* stdout and stderr 
* start- and stop- times 
* exit status.

It's really useful for wrapping around commands in cron, instead of relying on cron's very general purpose emails.

For convenience, Loggit also comes with an RSS generator, `exportrss`, that turns the contents of loggit.sqlite into an Atom feed.

## Setup ##

    git clone git://github.com/scraperwiki/loggit.git
    cd loggit
    npm install
    . activate

## Example: command line ##

    loggit ls -hitlr foo .
    sqlite3 scraperwiki.sqlite 'select * from loggit_event order by time desc limit 5'
    exportrss
    cat loggit-rss.xml

Of course `ls -hitlr foo .` is just an example command, you can run any command using `loggit`.
The example assumes your database is the default `scraperwiki.sqlite`.
    
## Example: crontab ##

    @daily cd loggit; loggit scrape.py; exportrss

## Running the tests ##

    # From the top-level directory "loggit"
    . activate
    mocha

## What's in the database? ##

Everything is in the `loggit_event` table.
`runid`: unique to each run.
`sequence`: events happen in order. runid+sequence is unique.
`type`: one of `start`, `stdout`, `stderr`, `exit`
`time`: the time that the event was recorded by loggit, in ISO 8601 format.  The system clock is used.  Generally the child process will buffer its output which means that the time that loggit sees the output will not be exactly the same time that the command wrote it.  Additionally, with lots of rapid output, it may be possible to get more than one event with exactly the same timestamp (use `sequence` to make them unique).
`pid` [start only]: pid number of the command
`command` [start only]: command line invoked
`data` [stdout, stderr]: text output from the command. Concatenate in order.
`exit_status` [exit only]: the exit status ($? in shell) of the completed command. Not used if exited with a signal, see `exit_signal`.
`exit_signal` [exit only]: the signal that killed the command, if any.  Not used for normal command completion.

# useful SQL

    select start.runid as runid, start.time, exit.time, start.pid as pid, start.command as command, exit.exit_signal as exit_signal, exit.exit_status as exit_status from (select * from loggit_event where runid = "0389088658383116102947926400229335" and type = "start") as start left join (select * from loggit_event where runid = "0389088658383116102947926400229335" and type = "exit") as exit ;

    select runid , group_concat (data,'') from loggit_event where type = "stdout" or type = "stderr" group by runid;


