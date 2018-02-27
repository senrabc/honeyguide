# This file is for resetting your docker environment when you need to.
# IT WILL DELETE VOLUMES. Be careful

yes | docker container prune
# yes | docker volume prune
# this keeps around the pg_admin volume so you dont need to entering your password
yes | docker volume rm honeyguide_postgres_data
yes | docker image prune
