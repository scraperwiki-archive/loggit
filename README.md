# logit

A tool to log stdout and stderr from a command, as well as
start- and stop- times and its exit status.

    logit ls -hitlr foo .
    sqlite3 logit.sqlite 'select*from logit_exit order by time desc limit 1' 
    # Try the logit_start and logit_data tables too.

