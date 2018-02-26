FROM python:3-stretch

ARG CAPPY_CLONE_URL
ARG QUAIL_CLONE_URL
ARG TOKEN
ARG REDCAP_URL
ARG PGPASSWORD

RUN useradd hcvprod

WORKDIR /home/hcvprod
RUN chown -R hcvprod /home/hcvprod

RUN apt-get update
RUN yes | apt-get install pgloader postgresql-client vim pwgen sqlite3

WORKDIR /home/hcvprod
RUN git clone $CAPPY_CLONE_URL
RUN git clone $QUAIL_CLONE_URL

RUN pip3 install -e ./cappy
RUN pip3 install -e ./QUAIL

USER hcvprod

RUN printf "*:*:*:postgres:" > /home/hcvprod/.pgpass
RUN printf $PGPASSWORD >> /home/hcvprod/.pgpass
RUN chmod 0600 /home/hcvprod/.pgpass

COPY --chown=hcvprod:hcvprod quail_run_script.sh ./

RUN quail install quailroot

WORKDIR quailroot

RUN quail redcap generate quail.conf.yaml hcvprod $TOKEN $REDCAP_URL

CMD "bash" "/home/hcvprod/quail_run_script.sh" "hcvprod"
