# Ghost docker-compose stack

Defition:
* ghost
* mysql
* (backup/restore script) to Openstack Swift

# Configuration
See customization variables in Makefile

# Start/Stop
Start/Stop the stack (ghost and mysql)
```
make up
make down
```

## Backup
Simple backup based on rclone and cron
* backup `DATA_DIR` and `DATA_DB_DIR`  as tar.gz
* Destination path to Openstack swift.
* Before launch backup, you need all Openstack variables defined in current shell (`OS_`)


```
# Source your os.rc
make install-rclone
make backup
```

A sample crontab script is available in `scripts`, to enable cron on current user
```
make enable-backup-cron
```

## Restore
```
make install-rclone
make restore up
```
