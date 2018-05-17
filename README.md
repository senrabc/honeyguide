# Purpose #

Honeyguide is a project meant to assist the HCV Target team with data analysis using QUAIL to pull
data and redash as the front end.

# Getting started #


## pre reqs ##

you need:
 1. docker (mac $ brew install docker)
 2. compose (mac $ brew install docker-compose)
 3. docker app (mac $ brew cask install docker)
 4. Start docker app manually.
 5. increase memory to ~8gb or more
 6. if you want to keep your data out of the hands of git make a folder called
 'DANGER' in the root `mkdir DANGER`, this is ignored by git using the
 `.gitignore` file in the root. If you want to make it some other name you will
 need to edit the .gitignore. Be careful with your data, don't send it back to
 github.
Make sure you have docker, docker-compose and an internet connection.

Copy the `fake.env` file and rename it to `.env`.

Fill in the correct info. If you decide to change the redash password then make sure to change it
in the connection string as well.

Run ` $ docker-compose up --build `

Go to `localhost:8080` and log into redash!

See the list of running containers and their id's
 ` $ docker container ls `

Attach to a bash shell inside your container using the id from ls

` $ docker exec -it 289f3c2e66ec bash `  where [289f3c2e66ec] is the abbreviated
id you see in the list of running containers

you will get a shell that looks like

`$ root@289f3c2e66ec:/home/hcvprod# `

# Adding a datasource #

When using redash and adding a datasource you have two options. One is to use the postgres instance and
information, the other is to add the sqlite databases that are made by quail itself.

## Postgres databases ##

The only thing to note here is that the hostname of the postgres instance is the same as the key of the
service in the `docker-compose.yaml` file.

## Sqlite database ##

You can add the sqlite databases themselves as a redash datasource because they are mounted in the redash
container at `/quail_data`

# If a service is killed #

You need to increase the memory limit. There are different ways to do this based on how you are using
docker so you will have to look this up on your own.

# Running a pull without cron #

There is a script that can be run from the docker host once the containers are running that will
allow one to pull whenever they want.

# Running a pull to get latest HCV Target Redcap as sqlite3 db #

Configure your values in .env to point at the correct DB using a compatible API
key for you target REDCAP.
### WARNING:This takes an indeterminate amount of time. 20180517 run took:30 min
Run `$ ./pull_data_as_sqlite3.sh`

 ## find the data from your run
 1. connect to the shell of the 'honeyguide_quail_1' container, find the id with
   ` $ docker container ls `
 2. use the id to connect to the shell: ` $ docker exec -it 289f3c2e66ec bash `
   where [289f3c2e66ec] is the abbreviated id you see in the list of running
   containers
 3. look for your run, it should have today's date'
   ` $ cd /home/hcvprod/quailroot/batches/hcvprod/2018-05-17 `
 4. data in `redcap_data_files` will be in json format.
 5. WARNING!!: put the data in a secure place and don't just run the example
    script. SCP the data to the `DANGER` folder.
    `docker exec -it 289f3c2e66ec scp `
