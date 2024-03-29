
![logo](https://github.com/happychriss/DocumentBox-Server/blob/master/app/assets/images/documentbox_pic.jpg)

DocumentBox 
===========
(Refresh 07/2022: Rails 6 / Ruby 3 on Ubuntu22.04 LTS Server with systemd)

DocumentBox is a OpenSource „home use“ Document Management system that helps you to
easy scan, file and find your documents. It can run on a mini computer
as small as a Raspberry Pi on a NAS or an your local server . A scanner connected to the mini-computers
allows you to quickly scan your documents and file them directly from
your mobile phone or tablet.

**DocumentBox is made for the paranoid** 

All data is stored locally – only
sending your files fully encrypted for backup to the the cloud (Amazon
S3). The database and all configuration data is also automatically
encrypted and uploaded to S3.

**DocumentBox is made to save your time**

A unique work-flow keeps your desk clean and lets you find your documents in a second.

**DocumentBox is made to make fun**

Check out, how it looks and feels:
https://www.youtube.com/watch?v=xCD8ukdc4cc

**DocumentBox is flexible and mobile**

I have also developed a mobile-app that allows uploading documents using the camera of your mobile phone. 
The scanned files are stored on the phone and will be uploaded to the DocumentBox server only in your local
Wifi network to assure your data privacy. This mobile app is not part of this repository and may be published later.

Technical Overview
==================

DocumentBox can run on everything, a small PI or a home-server with OCR. All
documents are indexed in a DB and stored locally (e.g. on SD card) .
When running on small devices (PI) - OCR is hard work - but the design also allows to “outsource” this
action to any PC via a daemon program . An optional configurable hardware depending component allows to control the
scanner and even LEDs for the print process.

Installation
============

Table of Contents
=================

* [DocumentBox](#documentbox)
* [Technical Overview](#technical-overview)
* [Installation](#installation)
* [Prepare](#prepare)
  * [Fixed IP Address](#fixed-ip-address)
  * [Setup the user ‘docbox’](#setup-the-user-docbox)
* [Install SW](#install-sw)
    * [Standard Ubuntu Packages](#standard-ubuntu-packages)
    * [PhusionPassenger](#phusionpassenger)
* [Install DocumentBox Server](#install-documentbox-server)
    * [Download Source-code](#download-source-code)
    * [Configuration](#configuration)
        * [Subnet](#subnet)
        * [Folder Structure](#folder-structure)
        * [Credentials for DB and S3](#credentials-for-db-and-s3)
            * [Postgres Database](#postgres-database)
* [Backup and Encryption on Amazon S3](#backup-and-encryption-on-amazon-s3)
    * [SetUp Amazon S3 Bucket](#setup-amazon-s3-bucket)
    * [Configure gpg encryption](#configure-gpg-encryption)
* [Additional components](#additional-components)
    * [Nginx &amp; PhusionPassenger](#nginx--phusionpassenger)
      * [Background](#background)
    * [Sphinx](#sphinx)
    * [ImageMagick](#imagemagick)
* [Install DocumentBox Daemons](#install-documentbox-daemons)
    * [Download Software from GitHub](#download-software-from-github)
* [<strong>Configure Scanner</strong>](#configure-scanner)
  * [Instruction for S1300](#instruction-for-s1300)
* [Run DocumentBox](#run-documentbox)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->

Prepare 
===============

### Fixed IP Address 

You will need to configure the DocBox Server  with a fixed IP address, to make it
possible for the SW services to work and to reach the DocumentBox from
your home network.

Update following file
```bash
File: //etc/dhcpcd.con  

# fixed IP address for PI  
interface wlan0  
static ip_address=192.168.1.105/24 #enter your IP address  
static routers=192.168.1.1 # enter your gateway IP address
```

### Setup the user ‘docbox’

The installation instructions is assuming a user ‘docbox’ and a folder
structure as //home/docbox for the file system.

```bash
sudo adduser docbox
sudo adduser docbox sudo
```

**Logout and login with the new docbox user.**

Please check, you should not use "sudo" for any command, only if noted down.

Little tip, when using ssh to connect to , run to directly connect to the server without repeating password and passphrase: 
```bash
ssh-copy-id docbox@your server
```


Install SW 
======================

Standard Ubuntu Packages
---------------------------

```bash
# Ruby, NodeJS and Yarn via Package Managers (rvm,nvm,yarn)

# Install the basics
sudo apt-get update  
sudo apt-get upgrade
sudo apt-get install git nginx redis-server postgresql postgresql-client libmysqlclient-dev libpq-dev 
sudo apt-get install imagemagick poppler-utils unpaper tesseract-ocr tesseract-ocr-deu  sane gnupg2 cups cups-client cups-bsd libcups2-dev html2ps exactimage pdftk 

# RVM:Install not from ubuntu repository, mixed version , but from RVM:
\curl -sSL https://get.rvm.io | bash -s stable --ruby

# NodeJS: install via nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

# Yarn via https://classic.yarnpkg.com/en/docs/install/#debian-stable

# Install the SW needed by Rails
rvm install "ruby-3.1.2"

# Same issues with rvm and wrappers (used to call ruby commands outside of source folder)
cd Docbox
gem install gem-wrappers
rvm wrappers generate

```
PhusionPassenger
--------------------------- 
PhusionPassenger is used as Application-Server together with Nginx, configuration below, installation:
```bash
# Install our PGP key and add HTTPS support for APT
sudo apt-get install -y dirmngr gnupg
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

# Add our APT repository
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger focal main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update

# Install Passenger + Nginx module
sudo apt-get install -y libnginx-mod-http-passenger

# enable the Passenger Nginx module and restart Nginx
if [ ! -f /etc/nginx/modules-enabled/50-mod-http-passenger.conf ]; then sudo ln -s /usr/share/nginx/modules-available/mod-http-passenger.load /etc/nginx/modules-enabled/50-mod-http-passenger.conf ; fi
sudo ls /etc/nginx/conf.d/mod-http-passenger.conf

```

Install DocumentBox Server
==========================

Download Source-code
--------------------

DocumentBox is hosted on GitHub an written in Ruby On Rails. It consists
out of 2 repository: DocBox-Server and DocBox-Daemons. First the Server
is installed.

Ruby manages the SW packages in “gems” - to prepare for this, login with
user docbox – execute below commands:
```bash
echo "gem: --no-ri --no-rdoc" >> ~/.gemrc
echo "export RAILS_ENV=production" >> ~/.bashrc
source ~/.bashrc
```

To download the source code and automatically install all Ruby
dependencies (gems):

```bash
cd
git clone https://github.com/happychriss/DocumentBox-Server.git
mv DocumentBox-Server DBServer #just to give the folder a shorter  name - IMPORTANT
cd DBServer
yarn install
gem install bundler
bundle update --bundler
bundle install
```

 Configuration
--------------------

###  Subnet
This is only needed when the IP address you server  does not start with
192.168.1.\*

Update below file with your subnet (last 3 group of your PI’s IP). Look for “192.168.1” and replace by your subnet.

```bash
Files: 
/home/docbox/DBServer/services/db_converter.service
/home/docbox/DBServer/services/db_scanner.service

```

### Folder Structure
All scanned files are stored in the file system as PDF and preview
images. This folder can be also located on an connected SD card . A link
from the DBServer folder to the data folder is also set-up.

```bash
sudo mkdir //data
cd //data
mkdir docstore  #//data/docstore is folder for documents stored locally
mkdir docstore_db #//data/docstore_db is folder for local database_backup (also uploaded to Amazon)
cd ..
sudo chown -R docbox:docbox //data
cd /home/docbox/DBServer
ln -s //data/docstore/ docstore
```

### Credentials for DB and S3  
DocBox is using Rails Secret and MasterKey approach. 
To secure this data on your server, the file is protected with a secret that you *must* never share or upload to github.
In this project the file is added to .gitignore.
Example credential file is provide in /config/credentials.example.yml.
You will need to create S3 storage and buckets for the documents uploaded and for a regular database backup. In addition
you will use the PGP email address to keep your private pgp key configured.
That file will be referred as 'credential-file' in the below sections.

```bash
cd DBServer
rm config/credentials.yml.enc # you dont want to use my config, you cant read it anyway :-)
#Create the secret
rails secret

#edit the file and update credentials
EDITOR=nano rails credentials:edit    
```

```yaml
# Used as the base secret for all MessageVerifiers in Rails, including the one protecting cookies.
secret_key_base: 444444444444444444444444444444444444444444444444

aws:
  access_key_id: 'your access key'
  secret_access_key: 'you secret access key'
  region: 'aws region,e.g. us-east-1'

production:
  postgres_password: 'your postgres pwd'
  postgres_user: 'your postgres user'
  aws_s3_bucket: 'your s3 bucket for files and document upload'
  aws_s3_db_bucket: 'your s3 bucket for the database backup'
  gpg_email_address: 'your email address to keep the private key for encryption'
```



#### Postgres Database 
Ruby on Rails provides support to set-up and create a database. You will
need user-name and password as selected when installing Postgres and update
it in the file database.yml . For setting- up initial Postgres user, follow the standard instructions.
Most simple to create a user "docbox", username and password should be updated in the credential-file.

```bash
# configure a user for postgres
sudo -u postgres createuser -P -d docbox
```

Now is assumed rails credentials are created and updated.

```bash

rake db:create
rake db:schema:load
rake db:seed #will just create default values in the DB
```

Comnpile the static assets

```bash
rake assets:precompile
```

Backup and Encryption on Amazon S3
=============================

DocumentBox is configured to use Amazon S3 Service for the backup of
scanned files and the database. Depending on your scanner, 1 file is
between 500kB and 1MB.

SetUp Amazon S3 Bucket
----------------------

You need to create to buckets, one for the files and the second one for
DB. You will need to collect the s3\_access\_key and s3\_secret\_key to
enable DocumentBox to upload files. The buckets should be named in the production section and updated in the credentials-file.
```text
production.docbox.com
production.docbox.db.com
```

Configure gpg encryption 
---------------------
All data uploaded to Amazon S3 will be encrypted using GPG Linux. Follow instructions by the program and accept the default values.
```bash
gpg --gen-key
```

Make sure to backup the key-pair, so you can encrypt your data when
downloading it from Amazon S3, the key is stored in the following folder
```bash
/home/docbox/.gnupg
```
The email address used for the key needs to be updated in the credentials-file  

Additional components
===============

Nginx & PhusionPassenger
----------------------

#### Background
DocBox is using Nginx as WebServer and Passenger as ApplicationServer, static assets (images, javascript) are precompiled and served by Nginx.
Passenger offers different installation options, I am using the standard nginx package and a passenger-module in an RVM environment that is added to nginx.
A full overview of the deployment is available here: https://www.phusionpassenger.com/docs/tutorials/deploy_to_production/deploying_your_app/oss/ownserver/ruby/nginx/
If keep the proposed set-up, no addition configuration needs to be done, only to copy the nginx.conf file.


```bash
cd DBServer
sudo mv //etc/nginx/nginx.conf //etc/nginx/nginx.conf.bak
sudo mv nginx.conf //etc/nginx/nginx.conf
```

Sphinx
----------------------
Sphinx is the search engine that creates an index and speeds it up when searching the documents.

```bash
cd DBServer
rake ts:rebuild
rake ts:index
```

 ImageMagick
----------------------
We are using convert to create jpg from PDF, here in the past where some security issues. We need to allow convert to 
do this by updating: 
```bash
//etc/ImageMagick-6
Change line from "none" to "read|write"
 <policy domain="coder" rights="read|write" pattern="PDF" />
```


Install DocumentBox Daemons
===========================

The daemons provide a modular system and can be configured to run on
different computers. Each daemon will use network discovery service to
find the DBServer and register it services. Therefore no IP
configuration is needed.

The following daemons are available:

**Scanner Daemon**

Connects the scanner and does prepare the scanned image for OCR
processing using UNPAPER.

**Converter Daemon**

Does all the heavy OCR work. Can run using abbyocr (for linux, no
freeware, but very fast and provides excellent OCR results) or
tesseract-ocr. Daemon is first checking for abbyocr and then for
tesseract-ocr.

**Hardware Daemon**

Not used in this version, allows to set LED or start&stop the scanning
process.

Download Software from GitHub
-----------------------------

```bash
cd
git clone https://github.com/happychriss/DocumentBox-Daemons.git
mv DocumentBox-Daemons/ DBDaemons # give it a short name
cd DBDaemons
bundle install
```

After completing the installation you should have the following folder
structure
```bash
home/docbox/DBServer #hosts the Web-server
home/docbox/DBDaemon # hosts the working processes
//data # host the scanned images
```

**Configure Scanner**
=====================

DocumentBox is using the Linux sane-library to communicate with the
scanner. I am using ScanSnap S1300 for scanning, as it support 2sided
pages and multiple pages scanning.

Only tested with ScanSnap S1300 – that requires some firmware download –
described here

[*https://www.josharcher.uk/code/install-scansnap-s1300-drivers-linux/*](https://www.josharcher.uk/code/install-scansnap-s1300-drivers-linux/)

### Instruction for S1300

```bash
cd
sudo mkdir /usr/share/sane/epjitsu
wget https://www.josharcher.uk/static/files/2016/10/1300_0C26.nal
sudo mv 1300_0C26.nal /usr/share/sane/epjitsu
sudo gpasswd -a docbox scanner
```

Check if it is working with:

```bash
scanimage -L
```

Output should be similar to „epjitsu:libusb:001:004' is a FUJITSU
ScanSnap S1300 scanner“
 
If scanimage only works with sudo user, create a file 55-libsane.rules in folder //etc/udev/rules.d with following content:
 ```bash
 ATTRS{idVendor}=="04c5", ATTRS{idProduct}=="11ed", GROUP="scanner", ENV{libsane_matched}="yes"
 ```
 

Autostart & Run DocumentBox
===============

**Background**

DocumentBox uses "systemd" as a framework to start and monitor the
application. systemd needs to have "services/units" files that define the programs started and its dependencies.

The service scripts are used to start additional services:
* db_avahi.service: Anounce the Docbox server to the Scanner/Converter Daemon. This allows to run this services on another server (e.g. for converting and OCR on a bigger machine) 
* db_clockwork.service / db_sidekiq.service: Job scheduling to regulary re-index the database and run a backup of all date to S3
* db_sphinx.service: Create the super fast search indes for full-text search
* db_scanner.service: This service needs to be on the same device/server as the scanner is connected via USB.
* db_converter.service: This service needs to be on server that has OCR capabilities, tesseract and adoby OCR are supported
* docbox.service: no logic hear, just the box that allows to start/stop all of the above services

The actual "Rails Server" is started as part of NGINX. The service for Nginx is created during the normal Nginx set-up.

**Setup autostart at boot using systemd**

You will need to copy the *.service files as admin into the systemd folder and activate the docbox.service for startup.

The following command will start the Server and Daemons in foreground to
check the start-up process.

```bash
cd DBServer/services
sudo cp *.service //etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable docbox.service
sudo systemctl start docbox

# Other useful systemd commands 
journalctl -f  #list all logfiles of above services
journalctl -fu db_converter  #list logfiles of a specific service

```

===
***Now you can reach the server in your local network:   http://192.168.1.106:8082***
===

Restore Database
===============
Files and Database is encrypted with gpg.
* Import private and public keyfiles with: gpg --import [keyfile]
* gpg -- decrypt file_from_aws > postgres_dump
* Create new database. e.g. with pgadmin
* pgadmin, select database, run restore, use user docbox

## Little Reminder - How to run in Development:

```bash
#Start Sphinx:
rake ts:start

#Start Avahi (Avahi is communicating the port of the web-server) 
ruby avahi_service_start_port.rb -p 8082 -e development 

#Start the Converter , port 8993 and 8991 need to be available, that how the server calls the service
cdclient_daemon.rb --service "Converter" --uid 3 --prio 12 --subnet "192.168.1" --port 8993 --avahiprefix "development"

#Start the Scanner
cdclient_daemon.rb --service "Scanner" --uid 1 --prio 12 --subnet "192.168.1" --port 8991 --avahiprefix "development" --unpaper_speed y

#Start DBServer on port 8082

#Credentials are encrypted the rails way: 
EDITOR="gedit --wait" rails credentials:edit
```