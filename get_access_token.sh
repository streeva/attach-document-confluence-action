#!/bin/bash
if [ "$#" -ne 3 ]; then
  echo "illegal number of parameters"
  exit 1
fi

CLIENTID=$1
CLIENTSECRET=$2
REDIRECTURL=$3

urlencode() {
  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    case $c in
      [a-zA-Z0-9.~_-]) printf "$c" ;;
      *) printf '%s' "$c" | xxd -p -c1 |
        while read c; do printf '%%%s' "$c"; done ;;
    esac
  done
}

echo "Copy the following URL and visit using your browser:"
echo "https://auth.atlassian.com/authorize?audience=api.atlassian.com&client_id=$CLIENTID&scope=read%3Aconfluence-content.summary%20write%3Aconfluence-file%20offline_access&redirect_uri=$(urlencode $REDIRECTURL)&state=1234&response_type=code&prompt=consent"
echo "Follow the auth flow to grant your app the access it needs, and when redirected copy the parameter value for code and enter it below"

read -p "Enter code: "  CODE

TOKEN=$(curl -s --request POST --url 'https://auth.atlassian.com/oauth/token' \
  --header 'Content-Type: application/json' \
  --data '{"grant_type": "authorization_code","client_id": "'$CLIENTID'","client_secret": "'$CLIENTSECRET'","code": "'$CODE'","redirect_uri": "'$REDIRECTURL'"}') 

echo $TOKEN | jq -r .refresh_token