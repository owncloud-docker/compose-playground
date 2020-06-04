#!/bin/bash

if [ -z ${SHARD} ]; then 
  echo "no shard defined to run a backup for" && exit 1;
fi

if [ -z ${COPY_SERVER} ]; then 
  echo "no copy destination defined" && exit 1;
fi

if [ -z ${COPY_PATH} ]; then 
  echo "no copy path defined for destination server" && exit 1;
fi

QDB_PORT=${QDB_PORT-7777}
EOS_NS_PATH=${EOS_NS_PATH-/var/lib/quarkdb}
BACKUP_PATH=${BACKUP_PATH-${EOS_NS_PATH}/backups}

STATUS=$(redis-cli -p ${QDB_PORT} -a "$(cat /etc/eos.client.keytab)" raft-info | grep STATUS | awk '{print $2}')

if [ ${STATUS} = "LEADER" ]; then
  echo "[INFO] starting backup process on leader $(hostname -f).."
  
  # get raft checkpoint
  echo "[INFO] creating raft checkpoint.."
  redis-cli -p ${QDB_PORT} -a "$(cat /etc/eos.client.keytab)" raft-checkpoint ${BACKUP_PATH}
  
  # tar and send
  echo "[INFO] compressing quarkdb backup.."
  file=${SHARD}.$(date +%Y%m%d%H%M%S).tar.gz
  tar -czvf ${EOS_NS_PATH}/${file} ${BACKUP_PATH}
  
  # ship off tar file
  echo "[INFO] shipping quarkdb backup to ${COPY_SERVER}..."
  xrdcp ${EOS_NS_PATH}/${file} root://${COPY_SERVER}:1094/${COPY_PATH} 
  
  # delete everything else
  echo "[INFO] cleaning up files..."
  rm ${EOS_NS_PATH}/${file}
  rm -rf ${BACKUP_PATH}
  echo "[INFO] done!"
else
  exit 0
fi
