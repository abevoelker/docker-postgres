FROM       ubuntu:trusty
MAINTAINER Abe Voelker <abe@abevoelker.com>

# Ignore APT warnings about not having a TTY
ENV DEBIAN_FRONTEND noninteractive

ENV USERNAME postgres
ENV PASSWORD password
ENV VERSION  9.2

# Ensure UTF-8 locale
RUN echo "LANG=\"en_US.UTF-8\"" > /etc/default/locale &&\
  locale-gen en_US.UTF-8 &&\
  dpkg-reconfigure locales

# Install build dependencies
RUN apt-get install -y wget

# Add PostgreSQL Global Development Group apt source
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Add PGDG repository key
RUN wget -qO - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -

RUN apt-get update

# Install Postgres, PL/Python, PL/V8
RUN apt-get install -y \
  postgresql-$VERSION \
  postgresql-contrib-$VERSION \
  postgresql-server-dev-$VERSION \
  postgresql-plpython-$VERSION \
  postgresql-$VERSION-plv8

# Remove build dependencies and clean up APT and temporary files
RUN apt-get remove --purge -y wget &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./pg_hba.conf     /etc/postgresql/$VERSION/main/
COPY ./postgresql.conf /etc/postgresql/$VERSION/main/

# COPY sets ownership on this directory to root
RUN chown -R postgres:postgres /etc/postgresql/$VERSION/main

USER postgres

RUN /etc/init.d/postgresql start &&\
  psql --command "ALTER USER postgres WITH PASSWORD '$PASSWORD';" &&\
  /etc/init.d/postgresql stop

CMD ["/usr/lib/postgresql/9.2/bin/postgres", "-D", "/var/lib/postgresql/9.2/main", "-c", "config_file=/etc/postgresql/9.2/main/postgresql.conf"]

# Expose Postgres log, configuration and storage directories
VOLUME ["/var/log/postgresql", \
        "/etc/postgresql/9.2/main", \
        "/var/lib/postgresql/9.2/main", \
        "/data"]

EXPOSE 5432
