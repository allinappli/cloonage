#!/bin/bash
##
## Développer par Renaud Fradin est Fawzy Elsam
##
################################################
##
##  Clonage site
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
echo "Choisissez ou cette instance doit etre cloner ?"
echo "Liste des domaines disponibles : "
echo " "
listSite=$(plesk bin site --list);
echo ${listSite[@]}
echo " "
read folder_destination
echo -e '\e[93m=============================================\033[0m'

cd $folder_clone/httpdocs
zip -r $folder_clone.zip *
cd ../..
cd $folder_destination/httpdocs

[[ "$(ls -A /)" ]] && deleteContente || mouveContent

mv $folder_clone/httpdocs/$folder_clone.zip $folder_destination/httpdocs

cd $folder_destination/httpdocs
unzip $folder_clone.zip
[[ ! -d "index.html" ]] && rm -rf index.html
rm -rf $folder_clone.zip
