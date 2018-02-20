while true; do
    echo "getting redcap metadata"
    # quail redcap get_meta $1
    echo "getting redcap data"
    # quail redcap get_data $1
    echo "generating the redcap metadata database"
    # quail redcap gen_meta $1
    echo "generating the redcap data database"
    # quail redcap gen_data $1
    echo "sleeping for 1 day"
    sleep 1d
done
