#!/bin/sh
/usr/bin/mc alias set minio http://minio:9000 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD};
/usr/bin/mc mb minio/${MINIO_BUCKET_NAME};
exit 0
