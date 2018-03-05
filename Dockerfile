# NOTE this image is not meant to be run on it's own. Please use docker-compose
FROM python:3-stretch

ARG CAPPY_CLONE_URL
ARG QUAIL_CLONE_URL
ARG PGPASSWORD

RUN apt-get update
RUN yes | apt-get install pgloader postgresql-client vim pwgen sqlite3 cron

RUN useradd hcvprod
RUN usermod -a -G crontab hcvprod

WORKDIR /home/hcvprod
RUN chown -R hcvprod /home/hcvprod

RUN git clone $CAPPY_CLONE_URL
RUN git clone $QUAIL_CLONE_URL

RUN pip3 install -e ./cappy
RUN pip3 install -e ./QUAIL

# RUN echo "TZ='America/New_York'; export TZ" > /etc/profile.d/timezone.sh

RUN quail install quailroot

RUN chown -R hcvprod:hcvprod ./quailroot

RUN chmod 0600 /etc/crontab

USER hcvprod

RUN echo "53 22 * * * bash /home/hcvprod/quail_run_script.sh > /proc/1/fd/1 2> /proc/1/fd/2" | crontab

RUN printf "*:*:*:postgres:" > /home/hcvprod/.pgpass
RUN printf $PGPASSWORD >> /home/hcvprod/.pgpass
RUN chmod 0600 /home/hcvprod/.pgpass

COPY --chown=hcvprod:hcvprod quail_run_script.sh fix_quail_unique_field.sql ./

USER root

CMD "echo" "\"Setup complete! QUAIL container ready for docker-compose up!\""
