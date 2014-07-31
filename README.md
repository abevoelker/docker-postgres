# Postgres Dockerfile

Docker image for Postgres 9.3 + WAL-E + PL/Python and PL/V8 languages

## Basic usage

```
$ docker run -p 5432:5432 abevoelker/postgres
2014-07-31 06:11:07 UTC LOG:  database system was shut down at 2014-07-31 05:52:53 UTC
2014-07-31 06:11:07 UTC LOG:  database system is ready to accept connections
2014-07-31 06:11:07 UTC LOG:  autovacuum launcher started
```

## WAL-E usage

This image comes with [WAL-E][wal-e] for performing continuous archiving of PostgreSQL WAL files and base backups.  To use WAL-E, you need to do a few things:

1. Create a directory with your secret environment variables (e.g. your AWS secret keys) in [envdir][envdir] format (one variable per file) and mount it as a volume overwriting `/etc/wal-e.d/env` when calling `docker run`.

2. Edit your `postgresql.conf` archive settings to use WAL-E. Changes should look something like this:

  ```
  wal_level = archive # hot_standby is also acceptable (will log more)
  archive_mode = on
  archive_command = 'envdir /etc/wal-e.d/env wal-e wal-push %p'
  archive_timeout = 60
  ```

3. Mount a volume to `/etc/cron.d` with a crontab for running your periodic WAL-E tasks (e.g. full backups, deleting old backups).  Here's an example that does a full backup daily at 2AM and deletes old backups (retaining 7 previous backups) at 3AM:

  ```
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  0 2 * * * postgres envdir /etc/wal-e.d/env wal-e backup-push /var/lib/postgresql/9.3/main
  0 3 * * * postgres envdir /etc/wal-e.d/env wal-e delete --confirm retain 7
  ```

4. Run the container with `/sbin/my_init` instead of the default command.  This is necessary to start cron, syslog, and Postgres.  In this mode, [runit][runit] manages the cron and Postgres processes and will restart them automatically if they crash.

Example `docker run` that covers basic WAL-E usage:

```
$ ls -1 /tmp/env
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
WALE_S3_PREFIX
$ ls -1 /tmp/cron
wal-e
$ cat /tmp/cron/wal-e
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
0 2 * * * postgres envdir /etc/wal-e.d/env wal-e backup-push /var/lib/postgresql/9.3/main
0 3 * * * postgres envdir /etc/wal-e.d/env wal-e delete --confirm retain 7
$ docker run -v /tmp/env:/etc/wal-e.d/env -v /tmp/cron:/etc/cron.d abevoelker/postgres /sbin/my_init
*** Running /etc/rc.local...
*** Booting runit daemon...
*** Runit started as PID 13
2014-07-31 06:11:07 UTC LOG:  database system was shut down at 2014-07-31 05:52:53 UTC
2014-07-31 06:11:07 UTC LOG:  database system is ready to accept connections
2014-07-31 06:11:07 UTC LOG:  autovacuum launcher started
```

## License

MIT license.

[wal-e]:  https://github.com/wal-e/wal-e
[envdir]: https://pypi.python.org/pypi/envdir
[runit]:  http://smarden.org/runit/
