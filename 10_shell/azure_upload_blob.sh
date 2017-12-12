#!/bin/bash
set -euxo pipefail

SAS=$1
STORAGE_ACCOUNT=myaccount
STORAGE_CONTAINER=distribution
STORAGE_SUFFIX="https://${STORAGE_ACCOUNT}.blob.core.windows.net/${STORAGE_CONTAINER}/testing/"

curl -X PUT -H "x-ms-blob-type: BlockBlob" -H "x-ms-blob-content-type: application/x-www-form-urlencoded" \
  "${STORAGE_SUFFIX}abc.file${SAS}" --data-binary "@/root/abc.file"
