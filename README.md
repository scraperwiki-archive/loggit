# loggit #

A tool to log what a command does to an SQLite database.

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

    loggit setup.py
    sqlite3 loggit.sqlite 'select * from loggit_event order by time desc limit 5'
    exportrss
    cat loggit-rss.xml
    
## Example: crontab ##

    @daily cd loggit; loggit setup.py; exportrss

## Running the tests ##

    . activate
    mocha