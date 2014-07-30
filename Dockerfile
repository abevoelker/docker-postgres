FROM       ubuntu:trusty
MAINTAINER Abe Voelker <abe@abevoelker.com>

ENV USERNAME postgres
ENV PASSWORD password
ENV VERSION  9.3

# Ensure UTF-8 locale
COPY locale /etc/default/locale
RUN locale-gen en_US.UTF-8 &&\
  dpkg-reconfigure locales

# Update APT
RUN DEBIAN_FRONTEND=noninteractive apt-get update

# Install build dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget

# Add PostgreSQL Global Development Group apt source
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Add PGDG repository key
RUN wget -qO - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -

RUN DEBIAN_FRONTEND=noninteractive apt-get update

# Install Postgres, PL/Python, PL/V8
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
  postgresql-$VERSION \
  postgresql-contrib-$VERSION \
  postgresql-server-dev-$VERSION \
  postgresql-plpython-$VERSION \
  postgresql-$VERSION-plv8 \
# Install WAL-E dependencies and supervisord
  libxml2-dev \
  libxslt1-dev \
  python-dev \
  python-pip \
  daemontools \
  libevent-dev \
  lzop \
  pv \
  supervisor &&\
  pip install virtualenv

# Install WAL-E into a virtualenv
RUN virtualenv /var/lib/postgresql/wal-e &&\
  . /var/lib/postgresql/wal-e/bin/activate &&\
  pip install wal-e &&\
  ln -s /var/lib/postgresql/wal-e/bin/wal-e /usr/local/bin/wal-e

# Create directory for storing secret WAL-E environment variables
RUN umask u=rwx,g=rx,o= &&\
  mkdir -p /etc/wal-e.d/env &&\
  chown -R root:postgres /etc/wal-e.d/env

# Remove build dependencies and clean up APT and temporary files
RUN DEBIAN_FRONTEND=noninteractive apt-get remove --purge -y wget &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy basic Postgres configs with values suitable for development
# (note: these should be overridden in production!)
COPY ./pg_hba.conf     /etc/postgresql/$VERSION/main/
COPY ./postgresql.conf /etc/postgresql/$VERSION/main/

# COPY sets ownership on this directory to root
RUN chown -R postgres:postgres /etc/postgresql/$VERSION/main

# Copy supervisord configs
COPY supervisord/cron.conf     /etc/supervisor/conf.d/
COPY supervisord/postgres.conf /etc/supervisor/conf.d/

USER postgres

RUN /etc/init.d/postgresql start &&\
  psql --command "ALTER USER postgres WITH PASSWORD '$PASSWORD';" &&\
  /etc/init.d/postgresql stop

USER root

# The image only runs Postgres by default. If you want to run periodic full
# backups with cron + WAL-E you should start supervisord instead (see README)
CMD ["su", "postgres", "-c", "/usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf"]

# Expose Postgres log, configuration and storage directories for backing up
VOLUME ["/var/log/postgresql", \
        "/var/log/supervisor", \
        "/etc/postgresql/9.3/main", \
        "/var/lib/postgresql/9.3/main"]

EXPOSE 5432
