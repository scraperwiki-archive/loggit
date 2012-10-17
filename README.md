# loggit #

A tool to log a command's activity to a SQLite database.

Prefixing your normal commands with `loggit` will capture:
* stdout and stderr 
* start- and stop- times 
* exit status.

It's really useful for wrapping around commands in cron, instead of relying on cron's very general purpose emails.

For convenience, Loggit also comes with an RSS generator, `exportrss`, that turns the contents of loggit.sqlite into an Atom feed.

## Setup ##

    git clone git@github.com:scraperwiki/loggit.git
    cd loggit
    npm install

## Example: command line ##

    loggit ls -hitlr foo .
    sqlite3 loggit.sqlite 'select * from loggit_event order by time desc limit 5'
    exportrss
    cat loggit-rss.xml

Of course `ls -hitlr foo .` is just an example command, you can run any command using `loggit`.
    
## Example: crontab ##

    @daily cd loggit; loggit scrape.py; exportrss

## Running the tests ##

    . activate
    mocha