FROM       ubuntu:12.04
MAINTAINER Abe Voelker <abe@abevoelker.com>

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" >> /etc/apt/sources.list
RUN apt-get update

# Install build dependencies
RUN apt-get install -y wget

# Install Postgres dependencies
RUN apt-get install -y libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt1-dev libssl-dev libpq-dev

# Add PostgreSQL Global Development Group apt source
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Add PGDG repository key
RUN wget -qO - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -

RUN apt-get update

# Install Postgres 9.3, PL/Python, PL/V8
RUN apt-get install -y postgresql-9.3 postgresql-contrib-9.3 postgresql-server-dev-9.3 postgresql-plpython-9.3 postgresql-9.3-plv8

EXPOSE 5432

ENTRYPOINT ["service", "postgresql", "start"]