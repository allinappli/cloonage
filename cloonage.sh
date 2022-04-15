#!/bin/bash
##
## Développer par Renaud Fradin est Fawzy Elsam
##
################################################
##
##  Cloonage site
##
################################################

cd ..
source cloonage/functions1.sh

echo -e '\e[93m=============================================\033[0m'
echo "Choisissez l'instance que vous vouler clonner ?"
echo "Liste des domaines disponibles : "
echo " "
listSite=$(plesk bin site --list);
echo ${listSite[@]}
echo " "
read folder_clone
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "Nom de la base de donnés de l'instance a clonner ?"
read mysql_clone_database
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "Nom de l'utilisateur de l'instance a clonner ?"
read mysql_clone_user
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "Choisissez ou cette instance doit etre cloner ?"
echo "Liste des domaines disponibles : "
echo " "
listSite=$(plesk bin site --list);
echo ${listSite[@]}
echo " "
read folder_destination
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "Nom de la base de donnés de l'instance ou elle va etre clonner ?"
read mysql_destination_database
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "Nom de l'utilisateur de l'instance ou elle va etre clonner ?"
read mysql_destination_user
echo -e '\e[93m=============================================\033[0m'



cd $folder_clone/httpdocs
sudo mysqldump -u $mysql_clone_user -p $mysql_clone_database > $folder_clone.sql
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

sudo mysql -u $mysql_destination_user -p $mysql_destination_database < $folder_clone.sql
[[ ! -d "index.html" ]] && rm -rf index.html
rm -rf $folder_clone.zip
rm -rf $folder_clone.sql
rm -rf httpdocs

echo -e '\e[93m================================================\033[0m'
echo -e '\e[1;32m Site cloner \032'
echo -e '\e[93m================================================\033[0m'