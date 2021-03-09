#!/bin/bash
if [ "$#" -ne 8 ]; then
  echo "illegal number of parameters"
  exit 1
fi

DOMAIN=$1
SPACEKEY=$2
PAGEHEADING=$3
ATTACHMENT_NAME=$4
SOURCE_FILE=$5
CLIENTID=$6
CLIENTSECRET=$7
REFRESH_TOKEN=$8

ACCESS_TOKEN=$(curl -s --request POST \
  --url 'https://auth.atlassian.com/oauth/token' \
  --header 'Content-Type: application/json' \
  --data '{ "grant_type": "refresh_token", "client_id": "'$CLIENTID'", "client_secret": "'$CLIENTSECRET'", "refresh_token": "'$REFRESH_TOKEN'" }' | jq -r .access_token)

CQL='cql=title="'$PAGEHEADING'" and Space='$SPACEKEY
SEARCHRESULTS=$(curl -s -G --url 'https://'$DOMAIN'.atlassian.net/wiki/rest/api/content/search' \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --data-urlencode "$CQL" \
  --data-urlencode 'limit=10' \
  --data-urlencode 'expand=body.storage,version,space')
#echo $SEARCHRESULTS
PAGE_ID=$( echo $SEARCHRESULTS | jq -r .results[].id)
echo Located page with $PAGE_ID

ATTACHMENTS=$(curl -s \
  --url 'https://'$DOMAIN'.atlassian.net/wiki/rest/api/content/'$PAGE_ID'/child/attachment?filename='$ATTACHMENT_NAME'.html&expand=version' \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header 'Accept: application/json')

EXISTING_ATTACHMENTID=$(echo $ATTACHMENTS | jq -r '.results[].id')

if [ -z "$EXISTING_ATTACHMENTID" ]
then
  # create
  echo "Existing attachment not found"
  curl -s --request POST \
    --url 'https://'$DOMAIN'.atlassian.net/wiki/rest/api/content/'$PAGE_ID'/child/attachment' \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "X-Atlassian-Token: no-check" \
    -F "file=@$SOURCE_FILE;filename=$ATTACHMENT_NAME.html"
else
  # update/replace
  echo "Existing attachment found"
  URL=https://$DOMAIN.atlassian.net/wiki/rest/api/content/$PAGE_ID/child/attachment/$EXISTING_ATTACHMENTID/data
  curl -s --request POST --url "$URL" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "X-Atlassian-Token: nocheck" \
    -F "file=@$SOURCE_FILE;filename=$ATTACHMENT_NAME.html"
fi