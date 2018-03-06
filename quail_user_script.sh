# -m preserves user environmental variables
# note that for some reason it HAS to come before the c flag
# I couldn't find this documented anywhere
echo "Starting quail pull"
su -mc 'bash /home/hcvprod/quail_run_script.sh' - hcvprod
