#!/bin/bash
set -x

NUMBER_OF_ATTEMPTS=10
SLEEP_TIME=3

URL=http://localhost:9000/test_connection/

# Ensure Tomcat is running by making an HTTPS GET request to the default page.
# Don't try and verify the certificate; use the --insecure flag.
for i in $(seq 1 $NUMBER_OF_ATTEMPTS);
do
  HTTP_CODE=$(curl --insecure --write-out '%{http_code}' -o /dev/null -m 10 -q -s --location $URL)
  if [ "$HTTP_CODE" == "200" ]; then
    echo "app server is running."
    exit 0
  fi
  echo "Attempt $i to curl endpoint returned HTTP Code $HTTP_CODE. Backing off and retrying."
  sleep $SLEEP_TIME
done
echo "Server did not come up after expected time. Failing."
exit 1