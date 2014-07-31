#!/usr/bin/env bash
chown -R root:root     /etc/cron.d
chmod -R 744           /etc/cron.d
chown -R root:postgres /etc/wal-e.d
chmod -R 750           /etc/wal-e.d
cron -f
