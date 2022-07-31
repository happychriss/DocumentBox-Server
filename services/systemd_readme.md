***Setup of systemd***
1) Copy all db*.service and docbox.service into //etc/systemd/system
2) Activate docbox.service as "enabled" so its triggered as boot (docbox will require remaining services)
3) nginx service is triggering Ruby on Rails

**Commands on Zo**

Defined sd/sj  command as alias in bash_alias

**Working with services**

Edit a service file: sd edit --full db_scanner
Start a service: sd start db_scanner
Stop a service: sd stop db_scanner

**Working with Journal**

Tail current log-entries: sj -f
Tail current entries for specific service: sj -fu db_scanner



