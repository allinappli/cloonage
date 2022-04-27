#!/bin/bash
##
## Développé par Renaud Fradin et Fawzy Elsam
##
################################################
##
##  Clonage site
##
################################################

cd ..
source cloonage/functions1.sh

echo -e '\e[93m=============================================\033[0m'
echo "Choisissez l'instance à cloner ?"
echo "Liste des domaines disponibles : "
echo " "
listSite=$(plesk bin site --list);
echo ${listSite[@]}
echo " "
read folder_clone
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "Nom de la base de données de l'instance à cloner ?"
read mysql_clone_database
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "Nom de l'utilisateur de l'instance à cloner ?"
read mysql_clone_user
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "MDP de l'utilisateur de l'instance à cloner ?"
read mysql_clone_mdp
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "Choisissez où cette instance doit être clonée ?"
echo "Liste des domaines disponibles : "
echo " "
listSite=$(plesk bin site --list);
echo ${listSite[@]}
echo " "
read folder_destination
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "Nom de la base de données de l'instance cible ?"
read mysql_destination_database
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "Nom de l'utilisateur de l'instance cible ?"
read mysql_destination_user
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "MDP de l'utilisateur de l'instance cible ?"
read mysql_destination_mdp
echo -e '\e[93m=============================================\033[0m'


cd $folder_clone/httpdocs
sudo mysqldump -u $mysql_clone_user -p$mysql_clone_mdp -D $mysql_clone_database > $folder_clone.sql
sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i $folder_clone.sql
cd ..
zip -r $folder_clone.zip httpdocs/

cd httpdocs
rm -rf $folder_clone.sql
cd ../..
cd $folder_destination/httpdocs

[[ "$(ls -A /)" ]] && deleteContente || mouveContent

mv $folder_clone/$folder_clone.zip $folder_destination/httpdocs

cd $folder_destination/httpdocs
unzip $folder_clone.zip

cd ..
mv httpdocs/httpdocs/* httpdocs
cd httpdocs

sudo mysql -u $mysql_destination_user -p$mysql_destination_mdp  -D $mysql_destination_database < $folder_clone.sql
[[ ! -d "index.html" ]] && rm -rf index.html
rm -rf $folder_clone.zip
rm -rf $folder_clone.sql
rm -rf httpdocs


# Modify website url
echo -e '\e[93m================================================\033[0m'
echo "Installation DBSearchReplace"
[[ `wget -S --spider https://github.com/DvdGiessen/DBSR/releases/download/2.2.0/DBSearchReplace-CLI.php  2>&1 | grep 'HTTP/1.1 200 OK'` ]] && wget https://github.com/DvdGiessen/DBSR/releases/download/2.2.0/DBSearchReplace-CLI.php || exit 1
[[ ! -d "config.json" ]] && echo "" || rm touch config.json
echo '{ "options": { "CLI": { "output": "json" }, "PDO": {"hostname": "localhost", "port": 3306, "username": "'$mysql_destination_user'", "password": "'$mysql_destination_mdp'", "database": "'$mysql_destination_database'", "charset": "utf8" }, "DBSR": { "case-insensitive": false, "extensive-search": false, "search-page-size": 10000, "var-match-strict": true, "floats-precision": 5, "convert-charsets": true, "var-cast-replace": true, "db-write-changes": true, "handle-serialize": true } }, "search": ["https://'$folder_clone'"], "replace": ["https://'$folder_destination'"] }' | jq '.' > config.json
echo "Ouvrir ce lien afin de modifier les datas :" https://$folder_destination/DBSearchReplace-CLI.php?args=--file+config.json
echo -e '\e[93m================================================\033[0m'

#update wp-config
sed -i "s/`echo $mysql_clone_database`/`echo $mysql_destination_database`/" wp-config.php

cd wp-content/uploads/civicrm
#update civicrm.setting.php
sed -i "s/`echo $mysql_clone_database`/`echo $mysql_destination_database`/" civicrm.settings.php

echo -e '\e[93m================================================\033[0m'
echo -e '\e[1;32m Site cloné \032'
echo -e '\e[93m================================================\033[0m'
