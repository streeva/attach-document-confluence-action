#!/bin/bash
if [ "$#" -ne 7 ]; then
  echo "illegal number of parameters"
  exit 1
fi

DOMAIN=$1
SPACEKEY=$2
PAGEHEADING=$3
ATTACHMENT_NAME=$4
SOURCE_FILE=$5
EMAIL=$6
TOKEN=$7

CQL='cql=title="'$PAGEHEADING'" and Space='$SPACEKEY
SEARCHRESULTS=$(curl -s -G -u "$EMAIL:$TOKEN" --url 'https://'$DOMAIN'.atlassian.net/wiki/rest/api/content/search' \
  --data-urlencode "$CQL" \
  --data-urlencode 'limit=10' \
  --data-urlencode 'expand=body.storage,version,space')
#echo $SEARCHRESULTS
PAGE_ID=$( echo $SEARCHRESULTS | jq -r .results[].id)
echo Located page with $PAGE_ID

ATTACHMENTS=$(curl -s -u "$EMAIL:$TOKEN" --url 'https://'$DOMAIN'.atlassian.net/wiki/rest/api/content/'$PAGE_ID'/child/attachment?filename='$ATTACHMENT_NAME'&expand=version' --header 'Accept: application/json')

EXISTING_ATTACHMENTID=$(echo $ATTACHMENTS | jq -r '.results[].id')

if [ -z "$EXISTING_ATTACHMENTID" ]
then
  # create
  echo "Existing attachment not found"
  URL='https://'$DOMAIN'.atlassian.net/wiki/rest/api/content/'$PAGE_ID'/child/attachment'
else
  # update/replace
  echo "Existing attachment found"
  URL=https://$DOMAIN.atlassian.net/wiki/rest/api/content/$PAGE_ID/child/attachment/$EXISTING_ATTACHMENTID/data
fi

curl -s --request POST -u "$EMAIL:$TOKEN" --url "$URL" -H "X-Atlassian-Token: no-check" -F "file=@$SOURCE_FILE;filename=$ATTACHMENT_NAME"