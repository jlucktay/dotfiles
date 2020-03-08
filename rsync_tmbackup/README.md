# rsync_tmbackup.sh

Example of line to exclude:

``` shell
cf...p...... Library/Application Support/Google/Chrome/Profile 1/IndexedDB/https_web.whatsapp.com_0.indexeddb.blob/2/01/173
```

## Exclude

- all cache directories
- Chrome stuff

``` text
- /**/*cache*/
- Library/Application Support/Google/Chrome/
```
