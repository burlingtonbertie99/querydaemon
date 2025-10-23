#!/bin/bash



echo "Script execution commencing!"

#nohup swipl -g start_daemon -t halt querydemon.pl > /dev/null 2>&1 &
#sleep 6000

#echo $MYMESSAGE

#echo ${{ secrets.secret1 }}


#echo $${{ secrets.secret2 }}

# Run the function for backend




#swipl -g "pack_install(smtp,[interactive(false)])" -t halt 


#swipl -g start_daemon -t halt querydemon.pl


swipl -g "pack_install(smtp,[interactive(false)])" -t halt 


swipl -g start_daemon -t halt querydemon.pl





create_secrets() {

  mkdir -p backend	

  local dir="backend"
  echo "Entering $dir/ and creating secrets..."

  cd "$dir" || { echo "Failed to enter $dir"; exit 1; }

  # Ensure secrets/ directory exists
  mkdir -p secrets  

  # Ensure secrets/ is in .gitignore
  if [ ! -f ".gitignore" ]; then
    touch ".gitignore"
  fi

  if ! grep -qx "secrets/" ".gitignore"; then
    echo "secrets/" >> ".gitignore"
    echo "Added 'secrets/' to $dir/.gitignore"
  fi

  # Process the .env file and create secrets
 # Process the .env file and create secrets
  while IFS='=' read -r key value || [ -n "$key" ]; do
    # Skip comments or blank lines
    [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue

    key=$(echo "$key" | xargs)
    # Remove anything after '#' in the value (the comment)
    value=$(echo "$value" | sed 's/\s*#.*//' | xargs)

    echo "$value" > "secrets/$key"

    if docker secret ls --format '{{.Name}}' | grep -qx "$key"; then
      echo "Updating secret $key..."
      docker secret rm "$key" >/dev/null 2>&1
    fi

    docker secret create "$key" "secrets/$key" \
      && echo "Secret $key created successfully!" \
      || echo "Failed to create secret: $key"
  done < .env


  cd - > /dev/null || exit
}





#create_secrets 


echo "Script execution completed!"




















check_existing_file_pskc() {
  if [ ! -f /mnt/tokens/PSKC_STCD.XML ]; then
    echo "Fatal error: No 'PSKC_STCD.XML' found in mounted volume" && exit 1
  else
    echo "Using 'PSKC_STCD.XML' from mounted volume..."
  fi
}

check_existing_file_alias() {
  if [ ! -f /mnt/tokens/alias.txt ]; then
    echo "Fatal error: No 'alias.txt' found in mounted volume" && exit 1
  else
    echo "Using 'alias.txt' from mounted volume..."
  fi
}

check_existing_file_signer_user_cert() {
  if [ ! -f /mnt/signer-data/AdminClientTrustCa.cer ]; then
    echo "Fatal error: No 'AdminClientTrustCa.cer' found in mounted volume" && exit 1
  else
    echo "Using 'AdminClientTrustCa.cer' from mounted volume..."
    cp /mnt/signer-data/AdminClientTrustCa.cer .
  fi
}


set -e

#AUTH_SERVER_HOME="/opt/cryptomathic/authenticator/server"
#AUTH_TEST_HOME="/opt/cryptomathic/authenticator/test"
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/cryptomathic/authenticator/server/


check_existing_files_in_output_dir() {
  if [ "$(ls -A $AUTH_TEST_HOME/PerfData)" ]; then
    echo "Fatal error: Existing data detected in mounted volume '$AUTH_TEST_HOME/PerfData'"
    echo "Please remove any files in this directory prior to initializing Authenticator."
    exit 1
  fi
}

copy_simulated_cards_to_output() {
  echo "Copying simulated smart cards to mounted volume..."
  cp -rf $AUTH_TEST_HOME/SimulatedCards $AUTH_TEST_HOME/PerfData/
}

delete_perftest_reports() {
  rm -f $AUTH_TEST_HOME/PerfData/PerfTest-*
}

generate_tokens() {
  echo "Generating tokens..."

  cd $AUTH_TEST_HOME
  mono PerfTestConsole.exe /Init
  mono PerfTestConsole.exe /TokenType Static-Pwd /Prepare 100:0:0
  mono PerfTestConsole.exe /TokenType OATH-TOTP /Prepare 100
  cd /
}

initialize_authenticator() {
  check_existing_files_in_output_dir


  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/cryptomathic/authenticator/server/


  # service authenticator start
  # mono '/opt/cryptomathic/authenticator/server/Authenticator Server.exe'

  /opt/cryptomathic/authenticator/server/Authenticator --start

  ls -l /opt/cryptomathic/authenticator/server/
  ls -l /opt/cryptomathic/authenticator/test/

  # systemctl authenticator start


  sleep 10

  # service httpd restart

  # systemctl httpd restart

  generate_tokens
  # service authenticator stop

  /opt/cryptomathic/authenticator/server/Authenticator --stop

  # systemctl authenticator stop
  cat $AUTH_SERVER_HOME/Authenticator.log

  rename_tokens_for_signer
  copy_simulated_cards_to_output
  delete_perftest_reports

  echo "Initialization complete"
  touch /initialized
}

rename_tokens_for_signer() {
  echo "Preparing keys for Signer..."

  # Cannot rename straight to lowercase mounted volumes in Windows -_-
  mv $AUTH_TEST_HOME/PerfData/RMK.txt /tmp/rmk.txt
  mv /tmp/rmk.txt $AUTH_TEST_HOME/PerfData/rmk.txt

  mv $AUTH_TEST_HOME/PerfData/CTK.bin /tmp/ctk.bin
  mv /tmp/ctk.bin $AUTH_TEST_HOME/PerfData/ctk.bin

  mv $AUTH_TEST_HOME/PerfData/KMTK.bin /tmp/kmtk.bin
  mv /tmp/kmtk.bin $AUTH_TEST_HOME/PerfData/kmtk.bin

  mv $AUTH_TEST_HOME/PerfData/RSK.bin /tmp/rsk.bin
  mv /tmp/rsk.bin $AUTH_TEST_HOME/PerfData/rsk.bin

  mv $AUTH_TEST_HOME/PerfData/STK.bin /tmp/stk.bin
  mv /tmp/stk.bin $AUTH_TEST_HOME/PerfData/stk.bin

  source $AUTH_TEST_HOME/format.sh $AUTH_TEST_HOME/PerfData/TOTPDTK.txt $AUTH_TEST_HOME/PerfData/oath-totp\ dtk.txt
  source $AUTH_TEST_HOME/format.sh $AUTH_TEST_HOME/PerfData/rmk.txt $AUTH_TEST_HOME/PerfData/rmk.txt
}

start_authenticator() {
  # service authenticator start

  chmod +x /opt/cryptomathic/authenticator/server/Authenticator
  /opt/cryptomathic/authenticator/server/Authenticator service > Authenticator.log
  #find / -name  Authenticator.log

  sleep 10
  # service httpd restart
  echo "Authenticator server started"

  #ls -l /opt/cryptomathic/authenticator/server/

  #tail -f -n 31 $AUTH_SERVER_HOME/Authenticator.log

  tail -f -n 31 /Authenticator.log

}



#if [ -f /initialized ]; then
#  echo "Existing setup detected - resuming Authenticator..."
  # start_authenticator
#else
#  echo "No existing setup detected - initializing Authenticator..."
  # initialize_authenticator
#  start_authenticator


 #  sleep 10


 # echo Launching WYSIWYS PoC Authenticator User Initializer...

 # check_existing_file_pskc
 # check_existing_file_alias
 # check_existing_file_signer_user_cert

  #java -jar authenticator-ws-util.jar --host=$AUTHENTICATOR_HOST --static-pwd-path=$STATIC_PWD_PATH --oath-totp-path=$OATH_TOTP_PATH --oath-totp-pskc-path=$OATH_TOTP_PSKC_PATH --pskc-passphrase=$PSKC_PWD --alias-path=$ALIAS_PATH --output-path=$OUTPUT_PATH --signer-user=$SIGNER_USER --signer-host=$SIGNER_HOST --signer-port=$SIGNER_PORT
  #echo Done!



#fi

