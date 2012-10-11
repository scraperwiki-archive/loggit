# loggit

A tool to log stdout and stderr from a command, as well as
start- and stop- times and its exit status.

    loggit ls -hitlr foo .
    sqlite3 loggit.sqlite 'select * from loggit_exit order by time desc limit 1' 
    # Try the loggit_start and loggit_data tables too.

