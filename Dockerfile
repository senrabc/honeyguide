# NOTE this image is not meant to be run on it's own. Please use docker-compose
FROM python:3-stretch

ARG CAPPY_CLONE_URL
ARG QUAIL_CLONE_URL
ARG PGPASSWORD

RUN apt-get update
RUN yes | apt-get install pgloader postgresql-client vim pwgen sqlite3 cron

RUN useradd hcvprod

WORKDIR /home/hcvprod
RUN chown -R hcvprod /home/hcvprod

RUN git clone $CAPPY_CLONE_URL
RUN git clone $QUAIL_CLONE_URL

RUN pip3 install -e ./cappy
RUN pip3 install -e ./QUAIL

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# remember the hour ranges from 0-23 hours
ARG MINUTE
ARG HOUR
RUN printf "%s %s * * * bash /home/hcvprod/quail_user_script.sh > /proc/1/fd/1 2> /proc/1/fd/2\n" $MINUTE $HOUR \
    | crontab

USER hcvprod

RUN quail install quailroot

RUN printf "*:*:*:postgres:%s" $PGPASSWORD > /home/hcvprod/.pgpass
RUN chmod 0600 /home/hcvprod/.pgpass

COPY --chown=hcvprod:hcvprod quail_user_script.sh quail_run_script.sh fix_quail_unique_field.sql ./

USER root

CMD "cron" "-f"
