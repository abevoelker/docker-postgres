# Postgres Dockerfile

Docker image for Postgres 9.3 + WAL-E + PL/Python and PL/V8 languages

## WAL-E usage

This image comes with [WAL-E][wal-e] for performing continuous archiving of PostgreSQL WAL files and base backups.  To use WAL-E, you need to do a few things:

1. Create a directory with your secret environment variables (e.g. your AWS secret keys) in [envdir][envdir] format (one variable per file) and mount it as a volume overwriting `/etc/wal-e.d/env` when calling `docker run`.

2. Edit your `postgresql.conf` archive settings to use WAL-E. Changes should look something like this:

  ```
  wal_level = archive
  archive_mode = on
  archive_command = 'envdir /etc/wal-e.d/env wal-e wal-push %p'
  archive_timeout = 60
  ```

3. Mount a volume to `/etc/cron.d` with a crontab for running your periodic WAL-E tasks (e.g. full backups, deleting old backups).  Here's an example that does a full backup daily at 2AM and deletes old backups (retaining 7 previous backups) at 3AM:

  ```
  0 2 * * * postgres /usr/bin/envdir /etc/wal-e.d/env wal-e backup-push /var/lib/postgresql/9.3/main
  0 3 * * * postgres /usr/bin/envdir /etc/wal-e.d/env wal-e delete --confirm retain 7 /var/lib/postgresql/9.3/main
  ```

4. Run the container with supervisord instead of the default command (which just starts Postgres).  This is necessary to start both cron and Postgres.

An example `docker run` that covers some of this follows:

```
$ ls -1 /tmp/wal-e/env
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
WALE_S3_PREFIX
$ cat /tmp/wal-e/cron/wal-e
0 2 * * * postgres /usr/bin/envdir /etc/wal-e.d/env wal-e backup-push /var/lib/postgresql/9.3/main
0 3 * * * postgres /usr/bin/envdir /etc/wal-e.d/env wal-e delete --confirm retain 7 /var/lib/postgresql/9.3/main
$ docker run -v /tmp/wal-e/env:/etc/wal-e.d/env -v /tmp/wal-e/cron:/etc/cron.d abevoelker/postgres /usr/bin/supervisord -c /etc/supervisor/supervisord.conf -n
```

## License

MIT license.

[wal-e]:  https://github.com/wal-e/wal-e
[envdir]: https://pypi.python.org/pypi/envdir
