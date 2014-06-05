FROM       ubuntu:trusty
MAINTAINER Abe Voelker <abe@abevoelker.com>

# Ignore APT warnings about not having a TTY
ENV DEBIAN_FRONTEND noninteractive
ENV USERNAME postgres
ENV PASSWORD password

# Ensure UTF-8 locale
RUN echo "LANG=\"en_US.UTF-8\"" > /etc/default/locale
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

RUN apt-get update

# Install build dependencies
RUN apt-get install -y wget

# Add PostgreSQL Global Development Group apt source
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Add PGDG repository key
RUN wget -qO - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -

RUN apt-get update

# Install Postgres 9.3, PL/Python, PL/V8
RUN apt-get install -y \
  postgresql-9.3 \
  postgresql-contrib-9.3 \
  postgresql-server-dev-9.3 \
  postgresql-plpython-9.3 \
  postgresql-9.3-plv8

# Clean up APT and temporary files
RUN apt-get apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./pg_hba.conf     /etc/postgresql/9.3/main/
ADD ./postgresql.conf /etc/postgresql/9.3/main/

# ADD sets ownership on this directory to root
RUN chown -R postgres:postgres /etc/postgresql/9.3/main

USER postgres

RUN /etc/init.d/postgresql start &&\
  psql --command "ALTER USER postgres WITH PASSWORD '$PASSWORD';" &&\
  /etc/init.d/postgresql stop

CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]

# Expose Postgres log, configuration and storage directories
VOLUME ["/var/log/postgresql", \
        "/etc/postgresql/9.3/main", \
        "/var/lib/postgresql/9.3/main", \
        "/data"]

EXPOSE 5432
