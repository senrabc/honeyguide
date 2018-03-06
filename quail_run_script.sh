echo $(whoami)

if [ ! -d "/home/hcvprod/quailroot/sources/hcvprod" ]; then
    printf "No %s project defined, building the project from environment variables." hcvprod | echo
    echo "This is stored in a volume on the machine! Remember to clean up!"
    quail redcap generate quail.conf.yaml hcvprod $TOKEN $REDCAP_URL
fi

# Waiting while postgres comes up
sleep 5

# Download the data
echo "getting redcap metadata"
quail redcap get_meta hcvprod
echo "getting redcap data"
quail redcap get_data hcvprod
echo "generating the redcap metadata database"
quail redcap gen_meta hcvprod
echo "generating the redcap data database"
quail redcap gen_data hcvprod

# Setup the postgres server to take our new data
echo "making a new postgres database"
printf "CREATE DATABASE " > /home/hcvprod/new_database.sql
new_database=$(date | sed -e 's/[ :]/_/g' | tr '[:upper:]' '[:lower:]')
loading_user="pgloader"
random_password=$(pwgen -s 64 1)
printf $new_database >> /home/hcvprod/new_database.sql
printf ";\n" >> /home/hcvprod/new_database.sql
printf "CREATE USER %s WITH PASSWORD '%s';\n" $loading_user $random_password >> /home/hcvprod/new_database.sql
printf "GRANT ALL ON DATABASE %s TO %s;\n" $new_database $loading_user >> /home/hcvprod/new_database.sql
psql -h postgres -U postgres < /home/hcvprod/new_database.sql

# Load data into the postgres database
echo "loading the databases"
current_batch=$(ls /home/hcvprod/quailroot/batches/hcvprod | sort | tail -n 1)
sqlite_data=$(printf "sqlite:///home/hcvprod/quailroot/batches/hcvprod/%s/data.db" $current_batch)
sqlite_metadata=$(printf "sqlite:///home/hcvprod/quailroot/batches/hcvprod/%s/metadata.db" $current_batch)
postgres_connect=$(printf "postgresql://%s:%s@postgres/%s" $loading_user $random_password $new_database)
metadata_path=$(printf "/home/hcvprod/quailroot/batches/hcvprod/%s/metadata.db" $current_batch)
sqlite3 $metdata_path < /home/hcvprod/fix_quail_unique_field.sql
pgloader $sqlite_data $postgres_connect
pgloader $sqlite_metadata $postgres_connect

#Remove loading user
echo "REASSIGN OWNED BY pgloader TO postgres;" > /home/hcvprod/delete_loading_user.sql
echo "DROP OWNED BY pgloader;" >> /home/hcvprod/delete_loading_user.sql
echo "DROP ROLE pgloader;" >> /home/hcvprod/delete_loading_user.sql
psql -h postgres -U postgres < /home/hcvprod/delete_loading_user.sql
