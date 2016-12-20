#!/bin/sh

identifier="tidusjar/Ombi"
filename="Ombi.zip"
output_path="/tmp/Ombi.zip"
user_details=""

if [ -z ${API+x} ]; then 
  echo "no API login used"
else
  echo "using provided API details"
  user_details="-u $API"
fi

plex_remote=$(curl $user_details -sX GET https://api.github.com/repos/$identifier/releases/latest | awk '/browser_download_url/{print $4;exit}' FS='[""]')

rm -rf /app/Ombi

if [ "$DEV" = "1" ]; then
  python /get-dev.py
else
  curl -o $output_path -L "$plex_remote"
fi

unzip -o $output_path -d /tmp

mv /tmp/Release /app/Ombi
rm $output_path

cd /config

if [ ! -f /config/PlexRequests.sqlite ]; then
  sqlite3 PlexRequests.sqlite "create table aTable(field1 int); drop table aTable;" # create empty db
fi

# check for Backups folder in config
if [ ! -d /config/Backup ]; then
  echo "Creating Backup dir..."
  mkdir /config/Backup
fi


ln -s /config/PlexRequests.sqlite /app/Ombi/PlexRequests.sqlite
ln -s /config/Backup /app/Ombi/Backup

cd /app/Ombi
executable=$(ls | grep ".exe" | grep -v "Updater\|config")
mono $executable "${RUN_OPTS}"
