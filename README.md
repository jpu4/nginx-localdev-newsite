# nginx-localdev-newsite
> Quick start bash script to create a new nginx site on your localhost for development

I like having a nice portable environment as I travel with my little laptop and work on random projects. I keep a usb or sd card handy with daily backups because I often try out different linux distros and environments and it's important for me to be able to load up my webserver and files and pick back up where i left off.

This script allows me to keep a few folders under my home directory for easy work and backup.

* /home/user/websrv
* /home/user/websrv/backups
* /home/user/websrv/conf
* /home/user/websrv/logs
* /home/user/websrv/repos
* /home/user/websrv/sites

I edit **/etc/nginx/nginx.conf** and tell it to include my "conf" directory and I go on my way.

```include /home/user/websrv/conf/*.conf;```

The script will copy my default nginx conf template, rename it to match your sitename and replace the path details to match the script variables. Make sure you update the script variables to match your local environment.

I hope this makes your dev time more enjoyable.

If you have any feedback, I'm very open!

## Usage

**Option 1. Quick run allows you to add a sitename and have a default empty site created**

```sudo ./newsite.sh myproject```

**Option 2. Without arguments, it will prompt you for sitename and whether you want to load in a local zip file or a git repo, or again, you can get a quick empty site by choosing "n"**

```sudo ./newsite.sh```
