#!/bin/sh

# Check for local environment var of ORCA API KEY
usage() {
  if [ $# -gt 0 ]
  then
    local varname=$1
    echo "$varname is missing please set $varname and try again."
    echo
  fi
  exit 1;
}

[ -z "$ORCA_API_KEY" ] && usage ORCA_API_KEY

curl_installed=$(hash curl ; echo $?)

HEADERS[0]="accept: application/json"
HEADERS[1]="Content-Type: application/json"
API_URL="https://api.orcasecurity.io/api"

TOKEN=$(curl -sSL -X POST --url "${API_URL}/user/session"  -H "${HEADERS[0]}" -H "${HEADERS[1]}" -d "{ \"security_token\": \"${ORCA_API_KEY}\" }" | jq -r '.jwt.access')

HEADERS[2]="Authorization: Bearer ${TOKEN}"

echo "Example query: Vm with IngressPorts containing 22 AND HasPii and IsInternetFacing"
echo "Example query: Vm with IsInternetFacing"
echo
echo -n "Please type in your Orca SONAR query, then hit enter:  "
read sonarq
set -x
sonarq=${sonarq// /%20}
curl -sSL -X GET --url "${API_URL}/sonar/query?query=${sonarq}&get_results_and_count=true" -H "${HEADERS[1]}" -H "${HEADERS[2]}" | jq
