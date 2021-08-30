# Ghost docker-compose stack

Defition:
* ghost
* mysql
* (backup/restore script) to Openstack Swift

See customization variables in Makefile

# Start/Stop
Start/Stop the stack (ghost and mysql)
```
make up
make down
```

## Backup
Simple backup based on rclone
backup `DATA_DIR` and `DATA_DB_DIR`  as tar.gz
Destination path to Openstack swift.
Before launch backup, you need all Openstack variables defined in current shell (`OS_`)

```
# Source os.rc
make install-rclone
make backup
```
## Restore
```
make install-rclone
make restore up
```
