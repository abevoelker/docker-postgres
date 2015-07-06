#!/usr/bin/env bash
chown -R root:root         /etc/cron.{d,daily,hourly,monthly,weekly}
chmod -R 755               /etc/cron.{d,daily,hourly,monthly,weekly}
chown -R root:postgres     /etc/wal-e.d
chmod -R 750               /etc/wal-e.d
chown -R postgres:postgres /var/lib/postgresql/9.4
chown -R postgres:postgres /etc/postgresql/9.4/main
chmod -R 700               /etc/postgresql/9.4/main
