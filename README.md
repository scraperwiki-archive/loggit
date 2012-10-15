# loggit

A tool to log what a command does to an SQLite database. It logs:
* stdout and stderr 
* start- and stop- times 
* exit status.

Useful to wrap round commands in cron, instead of relying on cron's very
general purpose emails.

## Example use

    npm -f install
    loggit ls -hitlr foo .
    sqlite3 loggit.sqlite 'select * from loggit_event order by time desc limit 1' 


