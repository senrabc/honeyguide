#!/bin/bash
###############################################################################
# purpose: to have on shell script that will run to pull the latest version of
# HCV redcap DB into local SQLITE3 formated and normalized data tables.
# author(s): Christopher P. Barnes (senrabc@gmail.com, @senrabc)
# created: 20180517
# license: see LICENSE file.
###############################################################################

# CONFIG
COMPOSE_FILE='docker-compose.yml'


# STEPS
# check config


# start docker

 ## this only works on a mac
open -a Docker

 ## start up all the containers that will run the processes.
 ## TODO: some of these may not be needed. Figure out which ones and then only
 ## start the containers that need strating

eval  "docker-compose --file $COMPOSE_FILE up --build -d"

 ## Check to see if they are running now

eval "docker container ls"

 ## run the pull script manually. This will pull the data into the docker
 ## container 'honeyguide_quail_1'
## WARNING:This takes an indeterminate amount of time. 20180517 run took: XX min 
eval "./run_pull_in_container"
  # this is equivalent to running
  # 'docker exec honeyguide_quail_1 bash /home/hcvprod/quail_user_script.sh'

# go get the data and put in the `DANGER` folder

  ## check to see if the `DANGER` folder exists if not create it
