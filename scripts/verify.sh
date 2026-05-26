#!/bin/bash

set -e

if [ -z "$TARGET_URL" ]; then
  echo "TARGET_URL is not set"
  exit 1
fi

echo "Checking root endpoint"
curl -fsS "$TARGET_URL/"

echo "Checking alive endpoint"
curl -fsS "$TARGET_URL/health/alive"

echo "Checking ready endpoint"
curl -fsS "$TARGET_URL/health/ready"

echo "Checking notes endpoint"
curl -fsS -H "Accept: application/json" "$TARGET_URL/notes"

echo "Checking matrix endpoint"
curl -fsS "$TARGET_URL/matrix"

echo "Verification completed successfully"