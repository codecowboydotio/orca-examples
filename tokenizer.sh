#!/bin/bash

#AU key
# Note that you set your API key here, but I have several, so I an setting the API key for the AU Orca API here.
export ORCA_API_KEY=${ORCA_AU_API_KEY}

HEADERS[0]="accept: application/json"
HEADERS[1]="Content-Type: application/json"

# The API URL should be the URL for your region. In AU the following URL is correct. Check the openapi docs for the correct endpoint.
API_URL="https://app.au.orcasecurity.io/api"

f_jwt_decode() {
  sed 's/\./\n/g' <<< $(cut -d. -f1,2 <<< $1) | base64 --decode | jq
}

f_set_var() {
  local varname=$1
  shift
  eval "$varname=\"$@\""
}

f_usage() {
  if [ $# -gt 0 ]
  then
    local varname=$1
    echo "$varname is missing please set $varname and try again."
    echo
  fi
  echo "-r <token_id>: 		Delete the given token."
  echo "-g:  			GET ALL TOKENS"
  echo "-c:  			CREATE A NEW TOKEN"
  echo "-d <description>:	Token description (used with create)"
  echo "-n <name>:		Token name (used with create)"
  echo "-o <role>: 		Token role (used with create)"
  echo "-i [true|false]:        Set true or false to enable or disable integration token"
  echo "-x:			Turn on debug output"
  exit 1;
}

f_delete_token() {
token_to_be_deleted=$1
echo "Deleting token: $token_to_be_deleted..."
delete_token=$(curl -sSL -X DELETE -H "${HEADERS[1]}" -H "${HEADERS[2]}" --url "${API_URL}/auth/tokens/${token_to_be_deleted}" | jq)

if [ "${debug}" == "true" ]
then
  echo $delete_token | jq
fi
}

f_get_tokens() {
all_tokens=$(curl -sSL -X GET -H "${HEADERS[1]}" -H "${HEADERS[2]}" --url "${API_URL}/auth/tokens" | jq -r '.data[] | select(. != null )')

[ -z "$all_tokens" ] && echo "There are currently no tokens configured." && exit 1;

if [ "${debug}" == "true" ]
then
  echo $all_tokens | jq
else
  echo $all_tokens | jq -r '"Token ID: " + .id'
fi

}

f_create_token() {
new_token=$(curl -sSL -X POST -H "${HEADERS[1]}" -H "${HEADERS[2]}" --url "${API_URL}/auth/tokens/" -d "{\"name\": \"${NAME}\", \"description\":\"${DESCRIPTION}\", \"role\":\"${ROLE}\", \"is_integration_token\":\"${IS_INTEGRATION}\" }")

echo $new_token | jq -r '"Token ID: " + .data.id + "\n" + "Secret Key: " + .data.secret_key + "\n"'

if [ "${debug}" == "true" ]
then
  echo $new_token | jq
fi

}

JWT_TOKEN=$(curl -sSL -X POST --url "${API_URL}/user/session"  -H "${HEADERS[0]}" -H "${HEADERS[1]}" -d "{ \"security_token\": \"${ORCA_API_KEY}\" }" | jq -r '.jwt.access')



HEADERS[2]="Authorization: Bearer ${JWT_TOKEN}"


while getopts 'd:r:b:n:o:i:xgch' flag
do
  case "${flag}" in
    c) f_set_var create_token true ;;
    d) f_set_var DESCRIPTION ${OPTARG} ;;
    g) f_set_var get_token true ;;
    i) f_set_var IS_INTEGRATION ${OPTARG} ;;
    n) f_set_var NAME ${OPTARG} ;;
    o) f_set_var ROLE ${OPTARG} ;;
    r) f_set_var token_id ${OPTARG} ;;
    x) f_set_var debug true ;;
    h) f_usage ;;
  esac
done

[ $# = 0 ] && f_usage
[ -z "$ORCA_API_KEY" ] && f_usage ORCA_API_KEY
if [ "$get_token" == "true" ] 
then
  echo "Using URL"
  echo "-------------------"
  echo "$API_URL"
  echo ; echo 
  echo "Discovered Tokens"
  echo "-------------------"
  f_get_tokens
fi
if [ "${#token_id}" -gt 0 ]
then
  echo "Using URL"
  echo "-------------------"
  echo "$API_URL"
  echo ; echo 
  echo "Deleted Token"
  echo "-------------------"
  f_delete_token ${token_id}
fi
if [ "$create_token" == "true" ]
then
  if [ "${#NAME}" -gt 0 ] 
  then
    if [ "${#ROLE}" -gt 0 ] 
    then
      if [ "${#IS_INTEGRATION}" -gt 0 ]
      then
        if [ "${#DESCRIPTION}" -gt 0 ]
        then 
          echo "Using URL"
          echo "-------------------"
          echo "$API_URL"
          echo ; echo 
          echo "Created Token"
          echo "-------------------"
          f_create_token
        else
          echo "Token description is missing, please set via the -d option"
        fi #end of DESCRIPTION
      else
        echo "Integration token must be true or false"
      fi #end of IS_INTEGRATION
    else
      echo "Role is missing, please set via the -o option"
    fi #end of ROLE
  else
    echo "Token name is missing, please set via the -n option"
  fi #end of NAME
fi

if [ "$debug" == "true" ] 
then
  echo "*********************************"
  echo "*  JWT TOKEN                    *"
  echo "*********************************"
  f_jwt_decode $JWT_TOKEN
fi

