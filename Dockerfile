# NOTE this image is not meant to be run on it's own. Please use docker-compose
FROM python:3-stretch

ARG CAPPY_CLONE_URL
ARG QUAIL_CLONE_URL
ARG PGPASSWORD

RUN useradd hcvprod

WORKDIR /home/hcvprod
RUN chown -R hcvprod /home/hcvprod

RUN apt-get update
RUN yes | apt-get install pgloader postgresql-client vim pwgen sqlite3 cron

WORKDIR /home/hcvprod
RUN git clone $CAPPY_CLONE_URL
RUN git clone $QUAIL_CLONE_URL

RUN pip3 install -e ./cappy
RUN pip3 install -e ./QUAIL

USER hcvprod

RUN printf "*:*:*:postgres:" > /home/hcvprod/.pgpass
RUN printf $PGPASSWORD >> /home/hcvprod/.pgpass
RUN chmod 0600 /home/hcvprod/.pgpass

COPY --chown=hcvprod:hcvprod quail_run_script.sh fix_quail_unique_field.sql ./

RUN quail install quailroot

USER root

RUN chown -R hcvprod:hcvprod ./quailroot

USER hcvprod

WORKDIR quailroot

RUN (crontab -l ; echo "30 16 * * * bash /home/hcvprod/quail_run_script.sh > /proc/1/fd/1 2>/proc/1/fd/2") \
    | crontab


CMD "echo" "\"Setup complete! QUAIL container ready for docker-compose up!\""
