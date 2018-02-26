while true; do
    # # Download the data
    # echo "getting redcap metadata"
    # quail redcap get_meta $1
    # echo "getting redcap data"
    # quail redcap get_data $1
    # echo "generating the redcap metadata database"
    # quail redcap gen_meta $1
    # echo "generating the redcap data database"
    # quail redcap gen_data $1

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

    # Load data into the postgres databse
    echo "loading the databases"
    current_batch=$(ls /home/hcvprod/quailroot/batches/hcvprod | sort | tail -n 1)
    sqlite_data=$(printf "sqlite:///home/hcvprod/quailroot/batches/hcvprod/%s/data.db" $current_batch)
    sqlite_metadata=$(printf "sqlite:///home/hcvprod/quailroot/batches/hcvprod/%s/metadata.db" $current_batch)
    postgres_connect=$(printf "postgresql://%s:%s@postgres/%s" $loading_user $random_password $new_database)
    echo $sqlite_data
    echo $sqlite_metadata
    echo $loading_user
    echo $random_password
    echo $postgres_connect
    pgloader $sqlite_data $postgres_connect
    pgloader $sqlite_metadata $postgres_connect

    #Remove loading user
    printf "REVOKE ALL ON DATABASE %s FROM %s;\n" $new_database $loading_user > /home/hcvprod/delete_loading_user.sql
    printf "DROP USER %s;\n" $loading_user >> /home/hcvprod/delete_loading_user.sql
    psql -h postgres -U postgres < /home/hcvprod/delete_loading_user.sql


    # Need a long running process for the docker container
    echo "sleeping for 1 day"
    sleep 1d
done
