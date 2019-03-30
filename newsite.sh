#!/bin/bash

# 2019 James Ussery <James@Ussery.me>
# https://github.com/jpu4
#
## Usage
#
# 1. Quick run allows you to add a sitename and have a default empty site created
# sudo ./newsite.sh myproject
#
# 2. Without arguments, it will prompt you for sitename and whether you want to 
# load in a local zip file or a git repo, or again, you can get a quick empty site 
# by choosing "n"
#
# sudo ./newsite.sh


localUser=$SUDO_USER
nginxuser="nginx"
nginxgroup="nginx"
domainTLD="mylocal.lan"
dirWebRoot="/websrv"
dirSites="$dirWebRoot/sites"
dirLogs="$dirWebRoot/logs"
dirConf="$dirWebRoot/conf"
dirRepos="$dirWebRoot/repos"
nginxConfTemplate="$dirConf/nginx-conf-template"

if [ ! -d $dirWebRoot ] || [ ! -d $dirSites ] || [ ! -d $dirLogs ] || [ ! -d $dirConf ] || [ ! -d $dirRepos ]; then
    echo "Please modify variables in this script"
    echo "Paths missing"
    echo "Exiting"
    exit 1
fi

if [ ! -f "$dirConf/nginx-conf-template" ]; then
    echo "NGINX Config file is missing"
    echo "Exiting"
    exit 1
fi

if [ $1 ]
then

    # Set sitename to lowercase
    sitename="$(tr [A-Z] [a-z] <<< "$1")"

    dirThisSite=$dirSites/$sitename
    # Create Folder and initial index
    mkdir -p $dirThisSite
    touch $dirThisSite/index.php
    echo "<?php phpinfo(); ?>" > $dirThisSite/index.php

else

    read -e -i "$sitename" -p "Sitename: (ie. [mysite].$domainTLD) " siteName_in
    sitename="${siteName_in:-$sitename}"

    sitename="$(tr [A-Z] [a-z] <<< "$sitename")"

    dirThisSite=$dirSites/$sitename
    loadRepo="git"
    read -e -i "$loadRepo" -p "Load a repo? (local, git, or N) " loadRepo_in
    loadRepo="${loadRepo_in:-$loadRepo}"

    loadRepo="$(tr [A-Z] [a-z] <<< "$loadRepo")"

    case "$loadRepo" in
        [local]* )

            # Load local package from repo
            localRepoPath="$dirRepos/sample.zip"
            read -e -i "$localRepoPath" -p "Local repo path: " localRepoPath_in
            localRepoPath="${localRepoPath_in:-$localRepoPath}"

            if [ ! -f $localRepoPath ]; then
                echo "File not found! -- Try again."
                read -e -i "$localRepoPath" -p "Local repo path: " localRepoPath_in
                localRepoPath="${localRepoPath_in:-$localRepoPath}"
            fi

            mkdir -p $dirThisSite
            unzip $localRepoPath -d $dirSites
            echo "Unzipped the contents of $localRepoPath to $dirThisSite"

        ;;

        [git]* )

            # Load remote package from git repo
            read -p "git repo url: " gitRepoUrl

            gitRepoName=${gitRepoUrl##*/}
            gitProject=${gitRepoName%.*}
            echo $gitRepoName
            echo $gitproject

            cd $dirSites

            git clone $gitRepoUrl

            read -p "Save this git repo in your local repos path?: [Y/N] " saveRepoYN

            saveRepoYN="$(tr [A-Z] [a-z] <<< "$saveRepoYN")"
            if [ $saveRepoYN == 'y' ]
            then
                zip -r $dirRepos/$gitProject.zip $gitProject
                sudo chown $localUser:$localUser $dirRepos/$gitProject.zip
            fi
            # Rename gitproject folder to match sitename
            mv $gitProject $sitename
            cd $dirSites
        ;;

        [n]* )

            mkdir -p $dirThisSite
            touch $dirThisSite/index.php
            echo "<?php phpinfo(); ?>" > $dirThisSite/index.php

        ;;
    esac

fi

siteurl=$sitename.$domainTLD

# Permissions need to be corrected because we ran this script using sudo
sudo chown -R $nginxuser:$nginxgroup $dirThisSite
echo "Created $dirThisSite"

# Create NGINX Conf
cp $nginxConfTemplate $dirConf/$sitename.conf
sed -i -e "s|SITENAME|$sitename|g" "$dirConf/$sitename.conf"
sed -i -e "s|TLD|$domainTLD|g" "$dirConf/$sitename.conf"
sed -i -e "s|SITEROOT|$dirSites|g" "$dirConf/$sitename.conf"
sed -i -e "s|LOGROOT|$dirLogs|g" "$dirConf/$sitename.conf"

sudo chown -R $nginxuser:$nginxgroup $dirConf
echo "Created and updated $dirConf/$sitename.conf"

# Create HOSTS file entry
sudo echo "127.0.0.1 $siteurl" >> /etc/hosts
echo "Updated hosts file with 127.0.0.1 $siteurl"

# Restart NGINX to load the new config
sudo systemctl restart nginx
echo "NGINX Restarted"
echo ""
echo "New site is live at http://$siteurl"
